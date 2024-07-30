/**
 * Created by user on 2018/12/3.
 */

import KHcache,{
    QueryTypeOld,
    QueryTypeYwqqid,
    EventClearEvent,
} from "./lib/KHCache";
import packageVersion from "./package.json";

const KHCacheVersion = packageVersion.version;
if(__DEV__){
    console.log(`===============${packageVersion.name}V${KHCacheVersion}=================`);
}

export {
    KHcache,
    KHCacheVersion,
    QueryTypeOld,
    QueryTypeYwqqid,
    EventClearEvent,
};