const fs = require('fs').promises;
const path = require('path');
const logger = require('../config/logger');

// 文档解析库
const pdf = require('pdf-parse');
const mammoth = require('mammoth');
const csv = require('csv-parser');
const xlsx = require('xlsx');

class FileParseService {
  /**
   * 解析文件内容
   */
  static async parseFile(filePath, mimetype) {
    try {
      logger.info('开始解析文件', { filePath, mimetype });

      let parseResult = {
        contentType: 'unknown',
        text: '',
        metadata: {},
        chunks: [],
        errors: []
      };

      switch (mimetype) {
        case 'application/pdf':
          parseResult = await this.parsePDF(filePath);
          break;

        case 'text/plain':
          parseResult = await this.parseText(filePath);
          break;

        case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          parseResult = await this.parseDocx(filePath);
          break;

        case 'text/csv':
          parseResult = await this.parseCSV(filePath);
          break;

        case 'application/vnd.ms-excel':
        case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          parseResult = await this.parseExcel(filePath);
          break;

        case 'application/vnd.ms-powerpoint':
        case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
          parseResult = await this.parsePowerPoint(filePath);
          break;

        case 'audio/mpeg':
        case 'audio/wav':
        case 'audio/mp3':
          parseResult = await this.parseAudio(filePath);
          break;

        case 'image/jpeg':
        case 'image/png':
        case 'image/gif':
          parseResult = await this.parseImage(filePath);
          break;

        default:
          parseResult.errors.push(`不支持的文件类型: ${mimetype}`);
          logger.warn('不支持的文件类型', { mimetype });
      }

      // 生成文档切片
      if (parseResult.text && parseResult.text.length > 0) {
        parseResult.chunks = this.chunkText(parseResult.text);
      }

      logger.info('文件解析完成', {
        filePath,
        contentType: parseResult.contentType,
        textLength: parseResult.text.length,
        chunksCount: parseResult.chunks.length,
        hasErrors: parseResult.errors.length > 0
      });

      return parseResult;

    } catch (error) {
      logger.error('文件解析失败', { filePath, error: error.message, stack: error.stack });
      return {
        contentType: 'error',
        text: '',
        metadata: {},
        chunks: [],
        errors: [error.message]
      };
    }
  }

  /**
   * 解析PDF文件
   */
  static async parsePDF(filePath) {
    try {
      const dataBuffer = await fs.readFile(filePath);
      const data = await pdf(dataBuffer);

      return {
        contentType: 'pdf',
        text: data.text,
        metadata: {
          pages: data.numpages,
          info: data.info,
          version: data.version
        },
        chunks: [],
        errors: []
      };

    } catch (error) {
      logger.error('PDF解析失败', { filePath, error: error.message });
      return {
        contentType: 'pdf',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`PDF解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析文本文件
   */
  static async parseText(filePath) {
    try {
      const text = await fs.readFile(filePath, 'utf8');

      return {
        contentType: 'text',
        text: text,
        metadata: {
          encoding: 'utf8',
          length: text.length,
          lines: text.split('\n').length
        },
        chunks: [],
        errors: []
      };

    } catch (error) {
      logger.error('文本文件解析失败', { filePath, error: error.message });
      return {
        contentType: 'text',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`文本文件解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析DOCX文件
   */
  static async parseDocx(filePath) {
    try {
      const result = await mammoth.extractRawText({ path: filePath });
      
      return {
        contentType: 'docx',
        text: result.value,
        metadata: {
          length: result.value.length,
          messages: result.messages
        },
        chunks: [],
        errors: result.messages.filter(m => m.type === 'error').map(m => m.message)
      };

    } catch (error) {
      logger.error('DOCX解析失败', { filePath, error: error.message });
      return {
        contentType: 'docx',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`DOCX解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析CSV文件
   */
  static async parseCSV(filePath) {
    try {
      const results = [];
      const fileStream = require('fs').createReadStream(filePath);
      
      return new Promise((resolve) => {
        fileStream
          .pipe(csv())
          .on('data', (data) => results.push(data))
          .on('end', () => {
            const text = results.map(row => Object.values(row).join(' ')).join('\n');
            
            resolve({
              contentType: 'csv',
              text: text,
              metadata: {
                rows: results.length,
                columns: results.length > 0 ? Object.keys(results[0]).length : 0,
                headers: results.length > 0 ? Object.keys(results[0]) : []
              },
              chunks: [],
              errors: []
            });
          })
          .on('error', (error) => {
            logger.error('CSV解析失败', { filePath, error: error.message });
            resolve({
              contentType: 'csv',
              text: '',
              metadata: {},
              chunks: [],
              errors: [`CSV解析失败: ${error.message}`]
            });
          });
      });

    } catch (error) {
      logger.error('CSV解析失败', { filePath, error: error.message });
      return {
        contentType: 'csv',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`CSV解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析Excel文件
   */
  static async parseExcel(filePath) {
    try {
      const workbook = xlsx.readFile(filePath);
      const sheetNames = workbook.SheetNames;
      let allText = '';
      const metadata = {
        sheets: [],
        totalRows: 0,
        totalCells: 0
      };

      for (const sheetName of sheetNames) {
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = xlsx.utils.sheet_to_json(worksheet, { header: 1 });
        
        const sheetText = jsonData.map(row => row.join(' ')).join('\n');
        allText += `\n=== ${sheetName} ===\n${sheetText}\n`;

        metadata.sheets.push({
          name: sheetName,
          rows: jsonData.length,
          columns: jsonData.length > 0 ? Math.max(...jsonData.map(row => row.length)) : 0
        });

        metadata.totalRows += jsonData.length;
        metadata.totalCells += jsonData.reduce((sum, row) => sum + row.length, 0);
      }

      return {
        contentType: 'excel',
        text: allText.trim(),
        metadata: metadata,
        chunks: [],
        errors: []
      };

    } catch (error) {
      logger.error('Excel解析失败', { filePath, error: error.message });
      return {
        contentType: 'excel',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`Excel解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析PowerPoint文件（占位符实现）
   */
  static async parsePowerPoint(filePath) {
    try {
      // TODO: 实现PowerPoint解析
      // 可以使用 node-pptx 或其他库
      
      return {
        contentType: 'powerpoint',
        text: '',
        metadata: {
          message: 'PowerPoint解析功能待实现'
        },
        chunks: [],
        errors: ['PowerPoint解析功能待实现']
      };

    } catch (error) {
      logger.error('PowerPoint解析失败', { filePath, error: error.message });
      return {
        contentType: 'powerpoint',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`PowerPoint解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析音频文件（占位符实现）
   */
  static async parseAudio(filePath) {
    try {
      // TODO: 实现音频转文字功能
      // 可以集成 OpenAI Whisper 或其他语音识别服务
      
      const stats = await fs.stat(filePath);
      
      return {
        contentType: 'audio',
        text: '',
        metadata: {
          size: stats.size,
          message: '音频转文字功能待实现'
        },
        chunks: [],
        errors: ['音频转文字功能待实现']
      };

    } catch (error) {
      logger.error('音频解析失败', { filePath, error: error.message });
      return {
        contentType: 'audio',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`音频解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 解析图片文件（占位符实现）
   */
  static async parseImage(filePath) {
    try {
      // TODO: 实现OCR图片文字识别
      // 可以集成 Tesseract.js 或其他OCR服务
      
      const stats = await fs.stat(filePath);
      
      return {
        contentType: 'image',
        text: '',
        metadata: {
          size: stats.size,
          message: '图片文字识别功能待实现'
        },
        chunks: [],
        errors: ['图片文字识别功能待实现']
      };

    } catch (error) {
      logger.error('图片解析失败', { filePath, error: error.message });
      return {
        contentType: 'image',
        text: '',
        metadata: {},
        chunks: [],
        errors: [`图片解析失败: ${error.message}`]
      };
    }
  }

  /**
   * 智能文本切片
   */
  static chunkText(text, options = {}) {
    const {
      maxChunkSize = 1000,    // 最大块大小
      minChunkSize = 100,     // 最小块大小
      overlapSize = 100,      // 重叠大小
      preserveParagraphs = true  // 保持段落完整性
    } = options;

    if (!text || text.length === 0) {
      return [];
    }

    const chunks = [];
    let currentPosition = 0;

    while (currentPosition < text.length) {
      let chunkEnd = Math.min(currentPosition + maxChunkSize, text.length);
      
      // 如果不是最后一块，尝试在合适的地方断开
      if (chunkEnd < text.length) {
        // 优先在段落边界断开
        if (preserveParagraphs) {
          const paragraphBreak = text.lastIndexOf('\n\n', chunkEnd);
          if (paragraphBreak > currentPosition + minChunkSize) {
            chunkEnd = paragraphBreak + 2;
          }
        }
        
        // 其次在句子边界断开
        if (chunkEnd === currentPosition + maxChunkSize) {
          const sentenceBreak = text.lastIndexOf(/[。！？.!?]\s*/g, chunkEnd);
          if (sentenceBreak > currentPosition + minChunkSize) {
            chunkEnd = sentenceBreak + 1;
          }
        }
        
        // 最后在词语边界断开
        if (chunkEnd === currentPosition + maxChunkSize) {
          const wordBreak = text.lastIndexOf(' ', chunkEnd);
          if (wordBreak > currentPosition + minChunkSize) {
            chunkEnd = wordBreak + 1;
          }
        }
      }

      const chunkText = text.substring(currentPosition, chunkEnd).trim();
      
      if (chunkText.length > 0) {
        chunks.push({
          id: chunks.length,
          text: chunkText,
          startPosition: currentPosition,
          endPosition: chunkEnd,
          length: chunkText.length
        });
      }

      // 计算下一个块的起始位置，考虑重叠
      if (chunkEnd >= text.length) {
        break;
      }
      
      currentPosition = Math.max(chunkEnd - overlapSize, currentPosition + 1);
    }

    logger.info('文本切片完成', {
      originalLength: text.length,
      chunksCount: chunks.length,
      averageChunkSize: Math.round(chunks.reduce((sum, chunk) => sum + chunk.length, 0) / chunks.length)
    });

    return chunks;
  }

  /**
   * 提取文档摘要信息
   */
  static extractSummary(text, maxLength = 200) {
    if (!text || text.length === 0) {
      return '';
    }

    // 简单的摘要提取：取前几个句子
    const sentences = text.match(/[^。！？.!?]+[。！？.!?]+/g) || [];
    let summary = '';
    
    for (const sentence of sentences) {
      if (summary.length + sentence.length <= maxLength) {
        summary += sentence;
      } else {
        break;
      }
    }

    // 如果没有合适的句子，直接截取
    if (summary.length === 0) {
      summary = text.substring(0, maxLength) + (text.length > maxLength ? '...' : '');
    }

    return summary.trim();
  }

  /**
   * 提取关键词（简单实现）
   */
  static extractKeywords(text, count = 10) {
    if (!text || text.length === 0) {
      return [];
    }

    // 简单的关键词提取：统计词频
    const words = text
      .toLowerCase()
      .replace(/[^\w\s\u4e00-\u9fff]/g, '') // 保留字母、数字、中文
      .split(/\s+/)
      .filter(word => word.length > 1);

    const wordCount = {};
    words.forEach(word => {
      wordCount[word] = (wordCount[word] || 0) + 1;
    });

    // 排序并返回前N个关键词
    return Object.entries(wordCount)
      .sort(([,a], [,b]) => b - a)
      .slice(0, count)
      .map(([word, frequency]) => ({ word, frequency }));
  }
}

module.exports = FileParseService; 