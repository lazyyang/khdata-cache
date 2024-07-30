/**
 * Created by user on 2018/12/3.
 */
import {
    NativeModules,
    NativeEventEmitter,
} from 'react-native';

const KHDataCache = NativeModules.KHDataCache;
//查询利旧数据
export const QueryTypeOld = KHDataCache.QueryTypeOld;
//根据业务请求ID查询影像数据
export const QueryTypeYwqqid = KHDataCache.QueryTypeYwqqid;
//清除缓存的进度事件
export const EventClearEvent = KHDataCache.EventClearEvent;

export type ImageDataType = {
    imageCount:number,//图片总数
    ywqqid:string,//业务请求id
    yxlx:string,//影像类型
    khh:string,//客户号
    gyh:string,//柜员userid
    images:array,//图片路径
    ext:object|array,//扩展字段
};

export type QueryType = {
    queryType:number,//查询类型
    khh:?string,//客户号 当queryType为QueryTypeOld利旧数据是必传
    ywqqid:?string,//业务请求id 当queryType为QueryTypeYwqqid必传
};
const EventClearEventEmitter = new NativeEventEmitter(KHDataCache);
class KHCache{
    // 构造
    constructor() {
    }

    /**
     * 添加监听缓存清除进度事件
     * @param callBack回调事件
     */
    addClearProgressListener = (callBack:func = ({progress})=>{}) =>{
        this.emitter = EventClearEventEmitter.addListener(KHDataCache.EventClearEvent,callBack);
    }

    /**
     * 移除监听
     */
    removeClearProgressListener = () =>{
        this.emitter && this.emitter.remove();
        this.emitter = null;
    }
    /**
     * 初始化
     * @param timeout 缓存数据超时时间，默认24小时(单位秒)
     * @returns {code:1|-1 ,note:""}
     */
    setUp = async (timeout:number = 60*60*24)=>{
        return new Promise(async (resolve,reject)=>{
            try{
                const result = await KHDataCache.setUp(timeout);
                resolve(result);
            }catch(e){
                reject(e);
            }
        });

    }
    /**
     * {"imageCount":8,
     * "ywqqid":"382149",
     * "yxlx":"108",
     * "khh":"010000036889",
     * "gyh":"0",
     * "images":[
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161343754.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344190.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344463.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344736.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344991.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345263.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345535.jpg"},
     * {"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345790.jpg"}
     * ]
     * }
       保存影像数据
     * @param imageData 需要使用JSON.stringify的字符串
     * @returns {code:1|-1 ,note:""}
     */
    saveData = async (imageData:ImageDataType)=>{
        return new Promise(async (resolve,reject)=>{
            try{
                const result = await KHDataCache.saveData(imageData);
                resolve(result);
            }catch(e){
                reject(e);
            }
        });

    }
    /**
     *  查询利旧数据或根据业务请求ID查询影像数据
     * @param queryParams 直接传js对象
     * @returns {code:1|-1 ,note:"",records:[]}
     */
    query = async (queryParams:QueryType)=>{
        return new Promise(async (resolve,reject)=>{
            try{
                const result = await KHDataCache.query(queryParams);
                resolve(result);
            }catch(e){
                reject(e);
            }
        });

    }

    /**
     * 清除缓存
     * @returns {code:1|-1 ,note:""}
     */
    clearCache = async ()=>{
        return new Promise(async (resolve,reject)=>{
            try{
                const result = await KHDataCache.clearCache();
                resolve(result);
            }catch(e){
                reject(e);
            }
        });

    }


}

export default new KHCache();