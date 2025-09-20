export class KVStoreType {
  public key: string;
  public value: Uint8Array | string | number | boolean;
  public type: string;

  constructor(key: string, value: Uint8Array | string | number | boolean, type: string) {
    this.key = key;
    this.value = value;
    this.type = type;
  }
}