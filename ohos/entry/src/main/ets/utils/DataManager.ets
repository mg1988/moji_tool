import KVStore from "./KVStore";
import { distributedKVStore } from '@kit.ArkData';
import { Database } from '@ohos/dataorm';
import { DbHelper } from "./DbHelper";
import { PdfFile } from "../model/PdfFile";
import { Migration,GlobalContext } from '@ohos/dataorm';
import { ColumnType } from '@ohos/dataorm';
import { DaoMaster } from '@ohos/dataorm';
import UIAbility from '@ohos.app.ability.UIAbility';

export class DataManager{

  public static getKvStore(UIContext: UIContext):KVStore{
     return new KVStore(true,distributedKVStore.SecurityLevel.S2,UIContext);
  }

  async init(context: UIAbility){
    // regular SQLite database
    let helper: DbHelper = new DbHelper(context, "info.db");
    // 设定数据加密密钥，加密后不可变更，加密和非加密库暂不能切换（普通数据库不能在设定为加密库，加密库不能变更为普通库，一经生成不可变更）
    helper.setEncrypt(false);
    // 设置新的数据库版本,如果新版本中包含表更新实例将在这调用onUpgradeDatabase进行表更新
    await helper.setVersion(2)
    // 将所有的表(新增,修改,已存在)加到全局
    helper.setEntities(PdfFile);

    // Migration为表更新实例,也可调用Migration.backupDB对当前数据库进行备份
    let migration = new Migration("info.db", "NOTE", 1).addColumn("MONEYS", ColumnType.realValue);
    // 将所有表更新实例放到ExampleOpenHelper的父级中
    helper.setMigration(migration);
    let db: Database = await helper.getWritableDb();
    db.name = "info.db";
    GlobalContext.getContext().setValue("daoSession", new DaoMaster(db).newSession());
  }
}