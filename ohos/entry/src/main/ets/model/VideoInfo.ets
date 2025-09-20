@Observed
export class VideoInfo{
  public name:string ="";
  public size:number = 0;
  public videoTime:number = 0;
  public audioMap:PixelMap|null = null;
  public path:string = "";
  public text:string = "";
  public audioPath:string = "";
  public isLoading:boolean = false;
}