import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { PrivacyNoteDBInfo } from '../pages/Privacy/Note/PrivacyNoteItem';

// 隐私笔记数据库封装
class PrivacyNoteDB {
  // 操作数据库的实例
  private store: relationalStore.RdbStore | null = null
  // 数据库名称
  private tableName = 'privacyNote'
  // 创建数据库语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        title TEXT NOT NULL,
                        content TEXT NOT NULL,
                        date_added INTEGER NOT NULL
                      )`

  // 类的构造器
  constructor() {
    // 打开或创建数据库文件
    this.getStoreInstance().then((store) => {
      // 创建表格
      store.executeSql(this.sqlCreate)
    })
  }

  // 获取数据库操作的实例
  async getStoreInstance() {
    if (this.store) {
      return this.store
    }
    // 打开或创建数据库文件
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: 'guardian.db',
      securityLevel: relationalStore.SecurityLevel.S1 //安全等级（夸设备共享等级）
    })
    return this.store
  }

  async select(id?: number) {
    // 打开或创建数据库文件
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    if (id) {
      // 单个条件用equalTo
      predicates.equalTo('id', id)
    } else {
      // 根据id,进行倒序查询
      predicates.orderByDesc('id')
    }

    // 查询id为1，3，6的数据
    // predicates.in('id',[1,3,6])

    // 查询指定id和标题为123的数据  and是链接相当于 &&
    // predicates.equalTo('id',id)
    //   .and()
    //   .equalTo('title','123')

    // 查询3条数据
    // predicates.limitAs(3)

    // 偏移三条个数据后再取两条数据
    // predicates.offsetAs(3)
    //   .and()
    //   .limitAs(2)

    // 查询
    const resultSet = await store.query(predicates)
    // 查询行数
    // 踩坑，有可能会返回-1
    // const rowCount = resultSet.rowCount < 0 ? 0 : resultSet.rowCount
    const list: PrivacyNoteDBInfo[] = []
    while (resultSet.goToNextRow()) {
      // 方法一
      // 一个一个字段取值
      // const item: PrivacyNoteDBInfo = {
      //   id : resultSet.getLong(0),
      //   title:resultSet.getString(1),
      //   content:resultSet.getString(2),
      //   date_added:resultSet.getLong(3)
      // }

      // 方法二
      // api11之后可以一次取一行数据
      const item = resultSet.getRow() as PrivacyNoteDBInfo

      list.push(item)
    }
    // 释放结果集，释放资源
    resultSet.close()

    return list
  }

  async insert(value: PrivacyNoteDBInfo) {
    // 打开或创建数据库文件
    const store = await this.getStoreInstance()
    // 新增数据
    store.insert(this.tableName, value)
  }

  async update(value: PrivacyNoteDBInfo) {
    if (!value.id) {
      return Promise.reject()
    }
    // 打开或创建数据库文件
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 单个条件用equalTo
    predicates.equalTo('id', value.id)
    return store.update(value, predicates)
  }

  async delete(id: number) {
    // 打开或创建数据库文件
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 单个条件用equalTo
    predicates.equalTo('id', id)
    return store.delete(predicates)
  }
}

export const privacyNoteDB = new PrivacyNoteDB()