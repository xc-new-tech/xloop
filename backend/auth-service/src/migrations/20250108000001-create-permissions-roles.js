'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // 创建权限表
    await queryInterface.createTable('permissions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
        comment: '权限ID'
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
        unique: true,
        comment: '权限名称，如：read_users, create_knowledge_base'
      },
      displayName: {
        type: Sequelize.STRING(200),
        allowNull: false,
        comment: '权限显示名称，如：读取用户列表, 创建知识库'
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: '权限描述'
      },
      resource: {
        type: Sequelize.STRING(100),
        allowNull: false,
        comment: '权限对应的资源，如：users, knowledge_bases, documents'
      },
      action: {
        type: Sequelize.STRING(50),
        allowNull: false,
        comment: '权限对应的操作，如：read, create, update, delete'
      },
      module: {
        type: Sequelize.STRING(100),
        allowNull: false,
        comment: '权限所属模块，如：auth, knowledge, conversation'
      },
      isSystem: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
        comment: '是否为系统权限，系统权限不可删除'
      },
      priority: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
        comment: '权限优先级，数字越大优先级越高'
      },
      conditions: {
        type: Sequelize.JSONB,
        allowNull: true,
        comment: '权限条件，支持复杂的权限控制逻辑'
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        comment: '权限是否启用'
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '创建时间'
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '更新时间'
      }
    }, {
      comment: '系统权限表'
    });

    // 创建角色表
    await queryInterface.createTable('roles', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
        comment: '角色ID'
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
        unique: true,
        comment: '角色名称，如：admin, editor, viewer'
      },
      displayName: {
        type: Sequelize.STRING(200),
        allowNull: false,
        comment: '角色显示名称，如：系统管理员, 编辑者, 查看者'
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: '角色描述'
      },
      type: {
        type: Sequelize.ENUM('system', 'custom', 'organization'),
        defaultValue: 'custom',
        comment: '角色类型：system-系统角色, custom-自定义角色, organization-组织角色'
      },
      level: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
        comment: '角色等级，数字越大权限越高，用于角色继承'
      },
      parentRoleId: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: '父角色ID，支持角色继承'
      },
      isSystem: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
        comment: '是否为系统角色，系统角色不可删除'
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        comment: '角色是否启用'
      },
      settings: {
        type: Sequelize.JSONB,
        allowNull: true,
        comment: '角色设置，存储角色相关的配置信息'
      },
      createdBy: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: '创建者ID'
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '创建时间'
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '更新时间'
      }
    }, {
      comment: '系统角色表'
    });

    // 创建用户角色关联表
    await queryInterface.createTable('user_roles', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
        comment: '关联ID'
      },
      userId: {
        type: Sequelize.UUID,
        allowNull: false,
        comment: '用户ID',
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      roleId: {
        type: Sequelize.UUID,
        allowNull: false,
        comment: '角色ID',
        references: {
          model: 'roles',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      scope: {
        type: Sequelize.ENUM('global', 'organization', 'department', 'project'),
        defaultValue: 'global',
        comment: '权限作用域：global-全局, organization-组织, department-部门, project-项目'
      },
      scopeId: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: '作用域ID，根据scope类型决定具体含义'
      },
      grantedBy: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: '授权者ID',
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      grantedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '授权时间'
      },
      expiresAt: {
        type: Sequelize.DATE,
        allowNull: true,
        comment: '过期时间，null表示永不过期'
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        comment: '是否启用'
      },
      metadata: {
        type: Sequelize.JSONB,
        allowNull: true,
        comment: '附加元数据'
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '创建时间'
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '更新时间'
      }
    }, {
      comment: '用户角色关联表'
    });

    // 创建角色权限关联表
    await queryInterface.createTable('role_permissions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
        allowNull: false,
        comment: '关联ID'
      },
      roleId: {
        type: Sequelize.UUID,
        allowNull: false,
        comment: '角色ID',
        references: {
          model: 'roles',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      permissionId: {
        type: Sequelize.UUID,
        allowNull: false,
        comment: '权限ID',
        references: {
          model: 'permissions',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      grantedBy: {
        type: Sequelize.UUID,
        allowNull: true,
        comment: '授权者ID',
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        comment: '是否启用'
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '创建时间'
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        comment: '更新时间'
      }
    }, {
      comment: '角色权限关联表'
    });

    // 添加索引
    await queryInterface.addIndex('permissions', ['name'], { unique: true });
    await queryInterface.addIndex('permissions', ['resource', 'action'], { unique: true });
    await queryInterface.addIndex('permissions', ['module']);
    await queryInterface.addIndex('permissions', ['isActive']);

    await queryInterface.addIndex('roles', ['name'], { unique: true });
    await queryInterface.addIndex('roles', ['type']);
    await queryInterface.addIndex('roles', ['level']);
    await queryInterface.addIndex('roles', ['parentRoleId']);
    await queryInterface.addIndex('roles', ['isActive']);

    await queryInterface.addIndex('user_roles', ['userId', 'roleId'], { unique: true });
    await queryInterface.addIndex('user_roles', ['userId']);
    await queryInterface.addIndex('user_roles', ['roleId']);
    await queryInterface.addIndex('user_roles', ['scope', 'scopeId']);
    await queryInterface.addIndex('user_roles', ['isActive']);

    await queryInterface.addIndex('role_permissions', ['roleId', 'permissionId'], { unique: true });
    await queryInterface.addIndex('role_permissions', ['roleId']);
    await queryInterface.addIndex('role_permissions', ['permissionId']);
    await queryInterface.addIndex('role_permissions', ['isActive']);

    // 添加外键约束
    await queryInterface.addConstraint('roles', {
      fields: ['parentRoleId'],
      type: 'foreign key',
      name: 'fk_roles_parent_role',
      references: {
        table: 'roles',
        field: 'id'
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL'
    });
  },

  async down(queryInterface, Sequelize) {
    // 删除外键约束
    await queryInterface.removeConstraint('roles', 'fk_roles_parent_role');

    // 删除表（按依赖顺序）
    await queryInterface.dropTable('role_permissions');
    await queryInterface.dropTable('user_roles');
    await queryInterface.dropTable('roles');
    await queryInterface.dropTable('permissions');
  }
}; 