/**
 * 表示一个点的接口
 */
interface Point {
  x: number;
  y: number;
}

/**
 * 表示一个矩形区域的接口
 */
interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * OCR识别文本块中的单词模型
 */
export class OCRWord {
  value: string;
  cornerPoints: Array<Point>;

  constructor(value: string, cornerPoints: Array<Point>) {
    this.value = value;
    this.cornerPoints = this.sortCornerPoints(cornerPoints);
  }

  /**
   * 将角点按顺时针顺序排序（左上、右上、右下、左下）
   */
  private sortCornerPoints(points: Array<Point>): Array<Point> {
    // 计算中心点
    const center:Point = {
      x: points.reduce((sum, p) => sum + p.x, 0) / points.length,
      y: points.reduce((sum, p) => sum + p.y, 0) / points.length
    };

    // 计算每个点相对于中心点的角度
    return points.sort((a, b) => {
      const angleA = Math.atan2(a.y - center.y, a.x - center.x);
      const angleB = Math.atan2(b.y - center.y, b.x - center.x);
      return angleA - angleB;
    });
  }

  /**
   * 获取文本的边界框
   */
  getBoundingRect(): Rect {
    const xs = this.cornerPoints.map(p => p.x);
    const ys = this.cornerPoints.map(p => p.y);
    
    const x = Math.min(...xs);
    const y = Math.min(...ys);
    const width = Math.max(...xs) - x;
    const height = Math.max(...ys) - y;
    
    return { x, y, width, height };
  }

  /**
   * 获取文本的旋转角度（相对于水平方向）
   */
  getRotationAngle(): number {
    // 使用第一条边（左上到右上）计算旋转角度
    const GeneratedDestructArray_1 = this.cornerPoints;
    const p1 = GeneratedDestructArray_1[0];
    const p2 = GeneratedDestructArray_1[1];
    return Math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / Math.PI);
  }
}

/**
 * OCR识别文本行模型
 */
@Observed
export class OCRLine {
  value: string;
  cornerPoints: Array<Point>;
  words: Array<OCRWord>;
  delete:boolean = false;//默认是选中的
  constructor(value: string, cornerPoints: Array<Point>, words: Array<OCRWord>) {
    this.value = value;
    this.cornerPoints = this.sortCornerPoints(cornerPoints);
    this.words = words;
  }

  /**
   * 将角点按顺时针顺序排序（左上、右上、右下、左下）
   */
  private sortCornerPoints(points: Array<Point>): Array<Point> {
    // 计算中心点
    const center: Point = {
      x: points.reduce((sum, p) => sum + p.x, 0) / points.length,
      y: points.reduce((sum, p) => sum + p.y, 0) / points.length
    };

    // 计算每个点相对于中心点的角度
    return points.sort((a, b) => {
      const angleA = Math.atan2(a.y - center.y, a.x - center.x);
      const angleB = Math.atan2(b.y - center.y, b.x - center.x);
      return angleA - angleB;
    });
  }

  /**
   * 获取文本行的位置（左上角点）
   */
  getPosition(): Point {
    return this.cornerPoints[0];
  }

  /**
   * 获取文本行的边界框
   */
  getBoundingRect(): Rect {
    const xs = this.cornerPoints.map(p => p.x);
    const ys = this.cornerPoints.map(p => p.y);

    const x = Math.min(...xs);
    const y = Math.min(...ys);
    const width = Math.max(...xs) - x;
    const height = Math.max(...ys) - y;

    return {
      x,
      y,
      width,
      height
    };
  }

  /**
   * 获取文本行的旋转角度（相对于水平方向）
   */
  getRotationAngle(): number {
    // 使用第一条边（左上到右上）计算旋转角度
    const GeneratedDestructArray_2 = this.cornerPoints;
    const p1 = GeneratedDestructArray_2[0];
    const p2 = GeneratedDestructArray_2[1];
    return Math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / Math.PI);
  }

  /**
   * 计算文本行的平均字符高度
   */
  getAverageCharHeight(): number {
    return this.getBoundingRect().height;
  }

  /**
   * 判断是否为横向文本
   */
  isHorizontal(): boolean {
    const angle = Math.abs(this.getRotationAngle());
    return angle < 45 || angle > 135;
  }
}
/**
 * OCR识别文本块模型
 */
@Observed
export class OCRBlock{
  value: string;
  lines: Array<OCRLine>;

  constructor(value: string, lines: Array<OCRLine>) {
    this.value = value;
    this.lines = lines;
  }
}
/**
 * OCR识别结果模型
 */
interface GeneratedTypeLiteralInterface_6 {
  x: number;
  y: number;
  width: number;
  height: number;
}

@Observed
export class OCRResult {
  value: string;
  blocks: Array<OCRBlock>;

  constructor(value: string, blocks: Array<OCRBlock>) {
    this.value = value;
    this.blocks = blocks;
  }

  /**
   * 从API返回的JSON数据创建OCRResult实例
   */
  static fromJSON(jsonData: string): OCRResult {
    let data:OCRResult = JSON.parse(jsonData);
    
    // 转换blocks
    const blocks = data.blocks.map(block => {
      // 转换lines
      const lines = block.lines.map(line => {
        // 转换words
        const words = line.words.map(word => 
          new OCRWord(word.value, word.cornerPoints)
        );
        return new OCRLine(line.value, line.cornerPoints, words);
      });
      return new OCRBlock(block.value, lines);
    });

    return new OCRResult(data.value, blocks);
  }

  /**
   * 获取所有识别出的文本
   */
  getAllText(): string {
    return this.blocks.map(block => block.value).join('\n');
  }

  /**
   * 获取指定区域内的文本
   */
  getTextInRegion(region: GeneratedTypeLiteralInterface_6): string {
    let  textsInRegion:string[] = [];
    
    for (const block of this.blocks) {
      for (const line of block.lines) {
        const pos = line.getPosition();
        if (pos.x >= region.x && 
            pos.x <= region.x + region.width &&
            pos.y >= region.y && 
            pos.y <= region.y + region.height) {
          textsInRegion.push(line.value);
        }
      }
    }
    
    return textsInRegion.join('\n');
  }
}
