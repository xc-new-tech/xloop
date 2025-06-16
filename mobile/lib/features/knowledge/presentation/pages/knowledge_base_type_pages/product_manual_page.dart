import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../bloc/knowledge_base_bloc.dart';
import '../../bloc/knowledge_base_event.dart';
import '../../bloc/knowledge_base_state.dart';
import '../../../domain/entities/knowledge_base.dart';

class ProductManualPage extends StatefulWidget {
  final KnowledgeBase knowledgeBase;

  const ProductManualPage({
    super.key,
    required this.knowledgeBase,
  });

  @override
  State<ProductManualPage> createState() => _ProductManualPageState();
}

class _ProductManualPageState extends State<ProductManualPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟加载产品数据
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _products.addAll([
          Product(
            id: '1',
            name: '智能手机 Pro',
            status: ProductStatus.active,
            documentCount: 15,
            lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
            description: '最新款智能手机产品线',
          ),
          Product(
            id: '2',
            name: '无线耳机系列',
            status: ProductStatus.active,
            documentCount: 8,
            lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
            description: '高品质无线音频设备',
          ),
        ]);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndActions(),
          Expanded(
            child: _isLoading ? _buildLoading() : _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 28.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '产品手册管理',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '管理产品文档和技术资料',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatCard('产品数量', '${_products.length}'),
                SizedBox(width: 12.w),
                _buildStatCard('文档总数', '${_products.fold(0, (sum, p) => sum + p.documentCount)}'),
                SizedBox(width: 12.w),
                _buildStatCard('活跃产品', '${_products.where((p) => p.status == ProductStatus.active).length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              name: 'search_products',
              controller: _searchController,
              hintText: '搜索产品名称...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => _filterProducts(value ?? ''),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: Icon(
                Icons.filter_list,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.w,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无产品',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角按钮添加第一个产品',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openProductDetail(product),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: product.status == ProductStatus.active
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: product.status == ProductStatus.active
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: product.status == ProductStatus.active
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                product.status == ProductStatus.active ? '使用中' : '已停用',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: product.status == ProductStatus.active
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.description_outlined,
                    label: '${product.documentCount} 个文档',
                  ),
                  SizedBox(width: 12.w),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: _formatDate(product.lastUpdated),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleProductAction(value, product),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('查看详情'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('编辑'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'refresh',
                        child: ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text('刷新切片'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _filterProducts(String query) {
    // TODO: 实现产品搜索过滤
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选产品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('使用中'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('已停用'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增产品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              name: 'product_name',
              controller: nameController,
              label: '产品名称',
              hintText: '请输入产品名称',
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              name: 'product_description',
              controller: descController,
              label: '产品描述',
              hintText: '请输入产品描述',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CustomButton(
            text: '创建',
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addProduct(nameController.text, descController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _addProduct(String name, String description) {
    setState(() {
      _products.add(Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        status: ProductStatus.active,
        documentCount: 0,
        lastUpdated: DateTime.now(),
      ));
    });
  }

  void _openProductDetail(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打开产品详情: ${product.name}')),
    );
  }

  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'view':
        _openProductDetail(product);
        break;
      case 'edit':
        // TODO: 编辑产品
        break;
      case 'refresh':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('正在刷新 ${product.name} 的切片...')),
        );
        break;
    }
  }
}

// 产品数据模型
class Product {
  final String id;
  final String name;
  final String description;
  final ProductStatus status;
  final int documentCount;
  final DateTime lastUpdated;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.documentCount,
    required this.lastUpdated,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductStatus? status,
    int? documentCount,
    DateTime? lastUpdated,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      documentCount: documentCount ?? this.documentCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

enum ProductStatus {
  active,
  inactive,
} 