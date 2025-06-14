'use strict';

const { v4: uuidv4 } = require('uuid');

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const now = new Date();

    // 预定义权限ID
    const permissionIds = {
      // 用户管理权限
      'auth.users.read': uuidv4(),
      'auth.users.create': uuidv4(),
      'auth.users.update': uuidv4(),
      'auth.users.delete': uuidv4(),
      
      // 知识库权限
      'knowledge.knowledge_bases.read': uuidv4(),
      'knowledge.knowledge_bases.create': uuidv4(),
      'knowledge.knowledge_bases.update': uuidv4(),
      'knowledge.knowledge_bases.delete': uuidv4(),
      
      // 文档权限
      'knowledge.documents.read': uuidv4(),
      'knowledge.documents.create': uuidv4(),
      'knowledge.documents.update': uuidv4(),
      'knowledge.documents.delete': uuidv4(),
      
      // FAQ权限
      'knowledge.faqs.read': uuidv4(),
      'knowledge.faqs.create': uuidv4(),
      'knowledge.faqs.update': uuidv4(),
      'knowledge.faqs.delete': uuidv4(),
      
      // 对话权限
      'conversation.conversations.read': uuidv4(),
      'conversation.conversations.create': uuidv4(),
      'conversation.conversations.update': uuidv4(),
      'conversation.conversations.delete': uuidv4(),
      
      // 文件权限
      'files.files.read': uuidv4(),
      'files.files.upload': uuidv4(),
      'files.files.download': uuidv4(),
      'files.files.delete': uuidv4(),
      
      // 搜索权限
      'search.search.use': uuidv4(),
      'search.search.manage': uuidv4(),
      
      // 系统管理权限
      'system.admin.full': uuidv4(),
      'system.logs.read': uuidv4(),
      'system.settings.read': uuidv4(),
      'system.settings.update': uuidv4()
    };

    // 插入权限数据
    const permissions = [
      // 用户管理权限
      {
        id: permissionIds['auth.users.read'],
        name: 'read_users',
        displayName: '查看用户',
        description: '查看用户列表和用户详情',
        resource: 'users',
        action: 'read',
        module: 'auth',
        isSystem: true,
        priority: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['auth.users.create'],
        name: 'create_users',
        displayName: '创建用户',
        description: '创建新用户账户',
        resource: 'users',
        action: 'create',
        module: 'auth',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['auth.users.update'],
        name: 'update_users',
        displayName: '更新用户',
        description: '修改用户信息',
        resource: 'users',
        action: 'update',
        module: 'auth',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['auth.users.delete'],
        name: 'delete_users',
        displayName: '删除用户',
        description: '删除用户账户',
        resource: 'users',
        action: 'delete',
        module: 'auth',
        isSystem: true,
        priority: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },

      // 知识库权限
      {
        id: permissionIds['knowledge.knowledge_bases.read'],
        name: 'read_knowledge_bases',
        displayName: '查看知识库',
        description: '查看知识库列表和详情',
        resource: 'knowledge_bases',
        action: 'read',
        module: 'knowledge',
        isSystem: true,
        priority: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.knowledge_bases.create'],
        name: 'create_knowledge_bases',
        displayName: '创建知识库',
        description: '创建新的知识库',
        resource: 'knowledge_bases',
        action: 'create',
        module: 'knowledge',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.knowledge_bases.update'],
        name: 'update_knowledge_bases',
        displayName: '编辑知识库',
        description: '修改知识库信息和设置',
        resource: 'knowledge_bases',
        action: 'update',
        module: 'knowledge',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.knowledge_bases.delete'],
        name: 'delete_knowledge_bases',
        displayName: '删除知识库',
        description: '删除知识库及其所有内容',
        resource: 'knowledge_bases',
        action: 'delete',
        module: 'knowledge',
        isSystem: true,
        priority: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },

      // 文档权限
      {
        id: permissionIds['knowledge.documents.read'],
        name: 'read_documents',
        displayName: '查看文档',
        description: '查看文档内容',
        resource: 'documents',
        action: 'read',
        module: 'knowledge',
        isSystem: true,
        priority: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.documents.create'],
        name: 'create_documents',
        displayName: '创建文档',
        description: '创建新文档',
        resource: 'documents',
        action: 'create',
        module: 'knowledge',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.documents.update'],
        name: 'update_documents',
        displayName: '编辑文档',
        description: '修改文档内容',
        resource: 'documents',
        action: 'update',
        module: 'knowledge',
        isSystem: true,
        priority: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: permissionIds['knowledge.documents.delete'],
        name: 'delete_documents',
        displayName: '删除文档',
        description: '删除文档',
        resource: 'documents',
        action: 'delete',
        module: 'knowledge',
        isSystem: true,
        priority: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now
      }
    ];

    await queryInterface.bulkInsert('permissions', permissions);

    // 预定义角色ID
    const roleIds = {
      'super_admin': uuidv4(),
      'admin': uuidv4(),
      'editor': uuidv4(),
      'viewer': uuidv4()
    };

    // 插入角色数据
    const roles = [
      {
        id: roleIds.super_admin,
        name: 'super_admin',
        displayName: '超级管理员',
        description: '拥有系统所有权限的超级管理员',
        type: 'system',
        level: 100,
        isSystem: true,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: roleIds.admin,
        name: 'admin',
        displayName: '系统管理员',
        description: '拥有大部分管理权限的系统管理员',
        type: 'system',
        level: 90,
        parentRoleId: roleIds.super_admin,
        isSystem: true,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: roleIds.editor,
        name: 'editor',
        displayName: '编辑者',
        description: '可以创建和编辑内容的编辑者',
        type: 'system',
        level: 50,
        isSystem: true,
        isActive: true,
        createdAt: now,
        updatedAt: now
      },
      {
        id: roleIds.viewer,
        name: 'viewer',
        displayName: '查看者',
        description: '只能查看内容的普通用户',
        type: 'system',
        level: 10,
        isSystem: true,
        isActive: true,
        createdAt: now,
        updatedAt: now
      }
    ];

    await queryInterface.bulkInsert('roles', roles);

    // 角色权限关联（超级管理员拥有所有权限）
    const superAdminPermissions = Object.values(permissionIds).map(permissionId => ({
      id: uuidv4(),
      roleId: roleIds.super_admin,
      permissionId,
      isActive: true,
      createdAt: now,
      updatedAt: now
    }));

    // 管理员权限（除了某些超级管理员专用权限）
    const adminPermissionNames = [
      'auth.users.read', 'auth.users.create', 'auth.users.update',
      'knowledge.knowledge_bases.read', 'knowledge.knowledge_bases.create', 'knowledge.knowledge_bases.update', 'knowledge.knowledge_bases.delete',
      'knowledge.documents.read', 'knowledge.documents.create', 'knowledge.documents.update', 'knowledge.documents.delete',
      'knowledge.faqs.read', 'knowledge.faqs.create', 'knowledge.faqs.update', 'knowledge.faqs.delete',
      'conversation.conversations.read', 'conversation.conversations.create', 'conversation.conversations.update', 'conversation.conversations.delete',
      'files.files.read', 'files.files.upload', 'files.files.download', 'files.files.delete',
      'search.search.use', 'search.search.manage'
    ];
    
    const adminPermissions = adminPermissionNames.map(permName => ({
      id: uuidv4(),
      roleId: roleIds.admin,
      permissionId: permissionIds[permName],
      isActive: true,
      createdAt: now,
      updatedAt: now
    }));

    // 编辑者权限
    const editorPermissionNames = [
      'knowledge.knowledge_bases.read', 'knowledge.knowledge_bases.create', 'knowledge.knowledge_bases.update',
      'knowledge.documents.read', 'knowledge.documents.create', 'knowledge.documents.update',
      'knowledge.faqs.read', 'knowledge.faqs.create', 'knowledge.faqs.update',
      'conversation.conversations.read', 'conversation.conversations.create', 'conversation.conversations.update',
      'files.files.read', 'files.files.upload', 'files.files.download',
      'search.search.use'
    ];
    
    const editorPermissions = editorPermissionNames.map(permName => ({
      id: uuidv4(),
      roleId: roleIds.editor,
      permissionId: permissionIds[permName],
      isActive: true,
      createdAt: now,
      updatedAt: now
    }));

    // 查看者权限
    const viewerPermissionNames = [
      'knowledge.knowledge_bases.read',
      'knowledge.documents.read',
      'knowledge.faqs.read',
      'conversation.conversations.read', 'conversation.conversations.create',
      'files.files.read', 'files.files.download',
      'search.search.use'
    ];
    
    const viewerPermissions = viewerPermissionNames.map(permName => ({
      id: uuidv4(),
      roleId: roleIds.viewer,
      permissionId: permissionIds[permName],
      isActive: true,
      createdAt: now,
      updatedAt: now
    }));

    // 插入角色权限关联
    await queryInterface.bulkInsert('role_permissions', [
      ...superAdminPermissions,
      ...adminPermissions,
      ...editorPermissions,
      ...viewerPermissions
    ]);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('role_permissions', null, {});
    await queryInterface.bulkDelete('user_roles', null, {});
    await queryInterface.bulkDelete('roles', null, {});
    await queryInterface.bulkDelete('permissions', null, {});
  }
}; 