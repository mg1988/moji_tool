export class Navi{
    private static instance:Navi;
    private pageStack: NavPathStack = new NavPathStack();
    private uiContext?: UIContext;
    private NavigationManager(){

    }
    static  of(context: UIContext): Navi{
      Navi.getInstance().uiContext = context;
      return Navi.getInstance();
    }
    getStack(){
      return this.pageStack;
    }
   static getInstance(){
     if (Navi.instance == null) {
       Navi.instance = new  Navi();
     }
     return Navi.instance
   }
   static push(name:string){
     Navi.getInstance().pageStack.pushPath({name:name});
   }
   static  toPage(url: string,arg:object){
     Navi.getInstance().uiContext?.getRouter().pushUrl({url:url,params:arg});
   }
     back(){
      Navi.getInstance().uiContext?.getRouter().back();
   }
}