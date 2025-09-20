import { Id } from '@ohos/dataorm';
import { Entity, Columns } from '@ohos/dataorm';
import { Unique } from '@ohos/dataorm';
import { ColumnType } from '@ohos/dataorm';
// 注解对外开放部分：Column、Entity、Id、NotNull、Unique、Index、ToMany、ToOne、JoinEntity、OrderBy、Convert、Embedded、Transient、Union。
@Entity('PdfToImage')
export class PdfFile {
  @Id({ isPrimaryKey: true ,autoincrement:true})
  @Unique()
  @Columns({ columnName: 'ID', types: ColumnType.num })
  public  id: number = 0;
  @Columns({ columnName: 'FILEID', types: ColumnType.str })
  public fileId: string = "";





  @Columns({ columnName: 'TYPE', types: ColumnType.num })
  public type: number;



  @Columns({ columnName: 'FILENAME', types: ColumnType.str })
  public fileName: string;



  @Columns({ columnName: 'FILEPATH', types: ColumnType.str })
  public filePath: string;


  @Columns({ columnName: 'CREATETIME', types: ColumnType.num })
  public createTime: number;






  //todo 类中必须在constructor中声明所有非静态变量，用于反射生成列
  constructor( id?: number,fileName?: string, filePath?: string, createTime?: number,type?:number) {
    this.fileName = fileName!;
    this.filePath = filePath!;
    this.createTime = createTime!;
    this.type = type!;
    this.id =id!;
  }


}