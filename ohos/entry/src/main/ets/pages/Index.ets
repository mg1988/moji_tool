
import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos'
import { Navi } from '../Navi';

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('viewId') viewId: string = "";
  @State scaleTo: number = 0.5
  @State opacityVal: number = 0
  @State textOpacity: number = 0
  @State welcomeText: string = '欢迎使用默记工具箱！'
  // 每日一言数据
  @State quotes: string[] = [
    "书山有路勤为径，学海无涯苦作舟。",
    "宝剑锋从磨砺出，梅花香自苦寒来。",
    "路漫漫其修远兮，吾将上下而求索。",
    "天行健，君子以自强不息。",
    "山重水复疑无路，柳暗花明又一村。",
    "长风破浪会有时，直挂云帆济沧海。",
    "千磨万击还坚劲，任尔东西南北风。",
    "业精于勤，荒于嬉；行成于思，毁于随。",
    "不积跬步，无以至千里；不积小流，无以成江海。",
    "志不强者智不达，言不信者行不果。",
    "莫愁前路无知己，天下谁人不识君。",
    "海纳百川，有容乃大；壁立千仞，无欲则刚。",
    "纸上得来终觉浅，绝知此事要躬行。",
    "问渠那得清如许？为有源头活水来。",
    "欲穷千里目，更上一层楼。",
    "会当凌绝顶，一览众山小。",
    "采得百花成蜜后，为谁辛苦为谁甜。",
    "春蚕到死丝方尽，蜡炬成灰泪始干。",
    "落红不是无情物，化作春泥更护花。",
    "横眉冷对千夫指，俯首甘为孺子牛。",
    "人生自古谁无死？留取丹心照汗青。",
    "粉身碎骨浑不怕，要留清白在人间。",
    "不要人夸颜色好，只留清气满乾坤。",
    "千淘万漉虽辛苦，吹尽狂沙始到金。",
    "时人不识凌云木，直待凌云始道高。",
    "看似寻常最奇崛，成如容易却艰辛。",
    "纸上谈兵终觉浅，绝知此事要躬行。",
    "苟利国家生死以，岂因祸福避趋之。",
    "天下兴亡，匹夫有责。",
    "先天下之忧而忧，后天下之乐而乐。",
    "富贵不能淫，贫贱不能移，威武不能屈。",
    "老骥伏枥，志在千里；烈士暮年，壮心不已。",
    "鞠躬尽瘁，死而后已。",
    "捐躯赴国难，视死忽如归。",
    "位卑未敢忘忧国，事定犹须待阖棺。",
    "出师未捷身先死，长使英雄泪满襟。",
    "出师一表真名世，千载谁堪伯仲间。",
    "王师北定中原日，家祭无忘告乃翁。",
    "僵卧孤村不自哀，尚思为国戍轮台。",
    "夜阑卧听风吹雨，铁马冰河入梦来。",
    "遗民泪尽胡尘里，南望王师又一年。",
    "死去元知万事空，但悲不见九州同。",
    "劝君更尽一杯酒，西出阳关无故人。",
    "洛阳亲友如相问，一片冰心在玉壶。",
    "莫道桑榆晚，为霞尚满天。",
    "东边日出西边雨，道是无晴却有晴。",
    "沉舟侧畔千帆过，病树前头万木春。",
    "山不在高，有仙则名。水不在深，有龙则灵。"
  ]
  @State dailyQuote: string = ""

  // 创建一个导航控制器对象并传入Navigation
  aboutToAppear(): void {
    // 从50条语录中随机选择一条
    const randomIndex = Math.floor(Math.random() * this.quotes.length)
    this.dailyQuote = this.quotes[randomIndex];
    let string = this.dailyQuote.split("");
    this.dailyQuote = string.join("\n")
  }

  onPageShow() {
    // 第一阶段：LOGO浮现
    Navi.of(this.getUIContext())
  }
  @Builder
  componentBuilder(){
    Stack() {
      Text("天\n行\n健\n，\n君\n子\n以\n自\n强\n不\n息\n。")
        .fontSize(30)
        .fontColor("#000")
        .textAlign(TextAlign.Center)
    }
    .backgroundColor($r('app.color.start_window_background'))
    .width('100%')
    .height('100%')
  }
  build() {
    Column() {
      // FlutterPage({viewId: this.viewId})
      FlutterPage({
        viewId: this.viewId,
        splashScreenView: this.componentBuilder,
        xComponentType: XComponentType.TEXTURE
      }).backgroundColor(Color.Transparent)
    }
  }
  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}