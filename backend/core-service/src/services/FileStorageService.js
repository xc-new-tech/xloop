const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const logger = require('../config/logger');

class FileStorageService {
  constructor() {
    // 存储根目录
    this.storageRoot = process.env.FILE_STORAGE_PATH || path.join(__dirname, '../uploads/files');
    this.tempRoot = path.join(__dirname, '../uploads/temp');
    
    // 确保目录存在
    this.ensureDirectories();
  }

  /**
   * 确保存储目录存在
   */
  async ensureDirectories() {
    try {
      await fs.mkdir(this.storageRoot, { recursive: true });
      await fs.mkdir(this.tempRoot, { recursive: true });
      
      // 创建按年月分组的子目录
      const now = new Date();
      const yearMonth = `${now.getFullYear()}/${String(now.getMonth() + 1).padStart(2, '0')}`;
      const monthlyDir = path.join(this.storageRoot, yearMonth);
      await fs.mkdir(monthlyDir, { recursive: true });
      
      logger.info('存储目录初始化完成', { 
        storageRoot: this.storageRoot,
        tempRoot: this.tempRoot,
        monthlyDir 
      });
    } catch (error) {
      logger.error('存储目录初始化失败', { error: error.message });
      throw error;
    }
  }

  /**
   * 存储文件到永久位置
   */
  static async store(file, fileId) {
    const service = new FileStorageService();
    return await service.storeFile(file, fileId);
  }

  /**
   * 存储文件
   */
  async storeFile(file, fileId) {
    try {
      // 生成存储路径（按年月分组）
      const now = new Date();
      const yearMonth = `${now.getFullYear()}/${String(now.getMonth() + 1).padStart(2, '0')}`;
      const fileExtension = path.extname(file.originalname);
      const fileName = `${fileId}${fileExtension}`;
      const relativePath = path.join(yearMonth, fileName);
      const fullPath = path.join(this.storageRoot, relativePath);

      // 确保目标目录存在
      await fs.mkdir(path.dirname(fullPath), { recursive: true });

      // 移动文件从临时位置到永久位置
      await fs.copyFile(file.path, fullPath);
      
      // 验证文件是否正确存储
      const stats = await fs.stat(fullPath);
      if (stats.size !== file.size) {
        throw new Error('文件大小不匹配，可能存储失败');
      }

      logger.info('文件存储成功', {
        fileId,
        originalName: file.originalname,
        storedPath: relativePath,
        size: stats.size
      });

      return relativePath;

    } catch (error) {
      logger.error('文件存储失败', {
        fileId,
        originalName: file.originalname,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * 获取文件的完整路径
   */
  static async getFilePath(relativePath) {
    const service = new FileStorageService();
    return path.join(service.storageRoot, relativePath);
  }

  /**
   * 删除文件
   */
  static async delete(relativePath) {
    const service = new FileStorageService();
    return await service.deleteFile(relativePath);
  }

  /**
   * 删除文件
   */
  async deleteFile(relativePath) {
    try {
      const fullPath = path.join(this.storageRoot, relativePath);
      
      // 检查文件是否存在
      try {
        await fs.access(fullPath);
      } catch (error) {
        logger.warn('要删除的文件不存在', { relativePath, fullPath });
        return; // 文件不存在，认为删除成功
      }

      // 删除文件
      await fs.unlink(fullPath);
      
      logger.info('文件删除成功', { relativePath });

    } catch (error) {
      logger.error('文件删除失败', {
        relativePath,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * 检查文件是否存在
   */
  static async exists(relativePath) {
    const service = new FileStorageService();
    return await service.fileExists(relativePath);
  }

  /**
   * 检查文件是否存在
   */
  async fileExists(relativePath) {
    try {
      const fullPath = path.join(this.storageRoot, relativePath);
      await fs.access(fullPath);
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * 获取文件信息
   */
  static async getFileInfo(relativePath) {
    const service = new FileStorageService();
    return await service.getFileStats(relativePath);
  }

  /**
   * 获取文件统计信息
   */
  async getFileStats(relativePath) {
    try {
      const fullPath = path.join(this.storageRoot, relativePath);
      const stats = await fs.stat(fullPath);
      
      return {
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        accessed: stats.atime
      };

    } catch (error) {
      logger.error('获取文件信息失败', {
        relativePath,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * 复制文件
   */
  static async copy(sourceRelativePath, targetRelativePath) {
    const service = new FileStorageService();
    return await service.copyFile(sourceRelativePath, targetRelativePath);
  }

  /**
   * 复制文件
   */
  async copyFile(sourceRelativePath, targetRelativePath) {
    try {
      const sourcePath = path.join(this.storageRoot, sourceRelativePath);
      const targetPath = path.join(this.storageRoot, targetRelativePath);

      // 确保目标目录存在
      await fs.mkdir(path.dirname(targetPath), { recursive: true });

      // 复制文件
      await fs.copyFile(sourcePath, targetPath);

      logger.info('文件复制成功', {
        source: sourceRelativePath,
        target: targetRelativePath
      });

    } catch (error) {
      logger.error('文件复制失败', {
        source: sourceRelativePath,
        target: targetRelativePath,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * 移动文件
   */
  static async move(sourceRelativePath, targetRelativePath) {
    const service = new FileStorageService();
    return await service.moveFile(sourceRelativePath, targetRelativePath);
  }

  /**
   * 移动文件
   */
  async moveFile(sourceRelativePath, targetRelativePath) {
    try {
      const sourcePath = path.join(this.storageRoot, sourceRelativePath);
      const targetPath = path.join(this.storageRoot, targetRelativePath);

      // 确保目标目录存在
      await fs.mkdir(path.dirname(targetPath), { recursive: true });

      // 移动文件
      await fs.rename(sourcePath, targetPath);

      logger.info('文件移动成功', {
        source: sourceRelativePath,
        target: targetRelativePath
      });

    } catch (error) {
      logger.error('文件移动失败', {
        source: sourceRelativePath,
        target: targetRelativePath,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * 清理临时文件
   */
  static async cleanupTempFiles(olderThanHours = 24) {
    const service = new FileStorageService();
    return await service.cleanupTempDirectory(olderThanHours);
  }

  /**
   * 清理临时目录中的旧文件
   */
  async cleanupTempDirectory(olderThanHours = 24) {
    try {
      const cutoffTime = Date.now() - (olderThanHours * 60 * 60 * 1000);
      const files = await fs.readdir(this.tempRoot);
      let deletedCount = 0;

      for (const file of files) {
        const filePath = path.join(this.tempRoot, file);
        const stats = await fs.stat(filePath);

        if (stats.mtime.getTime() < cutoffTime) {
          await fs.unlink(filePath);
          deletedCount++;
        }
      }

      logger.info('临时文件清理完成', {
        totalFiles: files.length,
        deletedFiles: deletedCount,
        olderThanHours
      });

      return { totalFiles: files.length, deletedFiles: deletedCount };

    } catch (error) {
      logger.error('清理临时文件失败', { error: error.message });
      throw error;
    }
  }

  /**
   * 获取存储统计信息
   */
  static async getStorageStats() {
    const service = new FileStorageService();
    return await service.calculateStorageStats();
  }

  /**
   * 计算存储使用统计
   */
  async calculateStorageStats() {
    try {
      const stats = {
        totalFiles: 0,
        totalSize: 0,
        directories: {},
        tempFiles: 0,
        tempSize: 0
      };

      // 统计主存储目录
      await this.calculateDirectoryStats(this.storageRoot, stats, '');

      // 统计临时目录
      await this.calculateDirectoryStats(this.tempRoot, stats, 'temp', true);

      logger.info('存储统计计算完成', {
        totalFiles: stats.totalFiles,
        totalSizeGB: (stats.totalSize / (1024 * 1024 * 1024)).toFixed(2),
        tempFiles: stats.tempFiles,
        tempSizeGB: (stats.tempSize / (1024 * 1024 * 1024)).toFixed(2)
      });

      return stats;

    } catch (error) {
      logger.error('计算存储统计失败', { error: error.message });
      throw error;
    }
  }

  /**
   * 递归计算目录统计
   */
  async calculateDirectoryStats(dirPath, stats, prefix = '', isTemp = false) {
    try {
      const items = await fs.readdir(dirPath);

      for (const item of items) {
        const itemPath = path.join(dirPath, item);
        const itemStats = await fs.stat(itemPath);

        if (itemStats.isDirectory()) {
          const subPrefix = prefix ? `${prefix}/${item}` : item;
          await this.calculateDirectoryStats(itemPath, stats, subPrefix, isTemp);
        } else if (itemStats.isFile()) {
          if (isTemp) {
            stats.tempFiles++;
            stats.tempSize += itemStats.size;
          } else {
            stats.totalFiles++;
            stats.totalSize += itemStats.size;

            // 按目录分组统计
            const dirKey = prefix || 'root';
            if (!stats.directories[dirKey]) {
              stats.directories[dirKey] = { files: 0, size: 0 };
            }
            stats.directories[dirKey].files++;
            stats.directories[dirKey].size += itemStats.size;
          }
        }
      }
    } catch (error) {
      // 跳过无法访问的目录
      logger.warn('无法访问目录', { dirPath, error: error.message });
    }
  }

  /**
   * 生成安全的文件URL（如果需要直接访问）
   */
  static generateSecureUrl(relativePath, expiresInMinutes = 60) {
    // 生成临时访问令牌
    const timestamp = Date.now() + (expiresInMinutes * 60 * 1000);
    const payload = `${relativePath}:${timestamp}`;
    const token = crypto.createHmac('sha256', process.env.FILE_TOKEN_SECRET || 'default-secret')
      .update(payload)
      .digest('hex');

    return {
      url: `/api/files/secure/${encodeURIComponent(relativePath)}`,
      token: token,
      expires: timestamp
    };
  }

  /**
   * 验证安全URL令牌
   */
  static validateSecureToken(relativePath, token, timestamp) {
    try {
      // 检查是否过期
      if (Date.now() > timestamp) {
        return false;
      }

      // 验证令牌
      const payload = `${relativePath}:${timestamp}`;
      const expectedToken = crypto.createHmac('sha256', process.env.FILE_TOKEN_SECRET || 'default-secret')
        .update(payload)
        .digest('hex');

      return token === expectedToken;
    } catch (error) {
      logger.error('令牌验证失败', { error: error.message });
      return false;
    }
  }
}

module.exports = FileStorageService; 