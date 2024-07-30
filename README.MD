## khdata-cache

----------------------------

### 说明

```
    本组件只支持ios,唯一依赖原生数据库组件FMDB,提供了利旧影像数据保存、查询利旧数据、清除缓存
```

### 集成
>1、通过npm安装组件
```npm
    npm i khdata-cache --save

```
>2、ios通过cocoapods安装

```cocoapods
    pod 'khdata-cache', :path => '../node_modules/khdata-cache'
```

### api说明

**请求参数类型**

```javascript

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

    /**
         * 添加监听缓存清除进度事件
         * @param callBack回调事件
         */
        addClearProgressListener = (callBack:func = ({progress})=>{}) =>{}

        /**
         * 移除监听
         */
        removeClearProgressListener = () =>{}
        /**
         * 初始化
         * @param timeout 缓存数据超时时间，默认24小时(单位秒)
         * @returns {code:1|-1 ,note:""}
         */
        setUp = async (timeout:number = 60*60*24)=>{}
        /**
         * {"imageCount":8,
         * "ywqqid":"382149",
         * "yxlx":"108",
         * "khh":"010000036889",
         * "gyh":"0",
           "ext":{"key":"val"},
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
        saveData = async (imageData:ImageDataType)=>{}
        /**
         *  查询利旧数据或根据业务请求ID查询影像数据
         * @param queryParams 直接传js对象
         * @returns {code:1|-1 ,note:"",records:[]}
         */
        query = async (queryParams:QueryType)=>{}

        /**
         * 清除缓存
         * @returns {code:1|-1 ,note:""}
         */
        clearCache = async ()=>{}
```

### 调用列子

```javascript
import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View,} from 'react-native';

import {KHcache,QueryTypeOld,QueryTypeYwqqid} from "khdata-cache";

type Props = {};

export default class App extends Component<Props> {
    async componentWillMount() {
        try{
            const result = await KHcache.setUp(60*60*5);
            alert(JSON.stringify(result));
        }catch(e){
            alert(e.message||e.note);
        }
    }
    queryOldDatas = async ()=>{
        try{
            const result = await KHcache.query({queryType:QueryTypeOld,khh:"010000036889"});
            alert(JSON.stringify(result));
        }catch(e){
            alert(e.message||e.note);
        }
    }

    queryYWQQIDDatas = async ()=>{
        try{
            const result = await KHcache.query({queryType:QueryTypeYwqqid,ywqqid:"382149"});
            alert(JSON.stringify(result));
        }catch(e){
            alert(e.message||e.note);
        }
    }

    saveDatas = async ()=>{
        try{
            const data = {"ext":{"key":"val"},"imageCount":8,"ywqqid":"382149","yxlx":"109","khh":"010000036889","gyh":"0","images":[{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161343754.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344190.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344463.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344736.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161344991.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345263.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345535.jpg"},{"jpg":"C:\\Image\\fileupload\\0\\20181130\\382149\\161345790.jpg"}]};

            const result = await KHcache.saveData(JSON.stringify(data));
            alert(JSON.stringify(result));
        }catch(e){
            alert(e.message||e.note);
        }
    }

    clearDatas = async ()=>{
        try{
            const result = await KHcache.clearCache();
            alert(JSON.stringify(result));
        }catch(e){
            alert(e.message||e.note);
        }
    }
     componentDidMount() {
        KHcache.addClearProgressListener(({progress})=>{
            console.warn(progress);
        });



       //利旧数据
        //this.queryOldDatas();
         //根据业务请求ID获取影像数据
        //this.queryYWQQIDDatas();
         //保存数据或更新数据
         //this.saveDatas();
         //清除缓存
         this.clearDatas();
        //

    }

    componentWillUnmount() {
        KHcache.removeClearProgressListener();
    }
  render() {
    return (
      <View style={styles.container}>

      </View>
    );
  }
}

```
