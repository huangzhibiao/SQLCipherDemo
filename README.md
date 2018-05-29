# SQLCipherDemo   
# 使用说明      
在自己的工程创建一个Podfile文件,内容如下:   
target '自己的工程名称' do   
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks   
    use_frameworks!   
    # FMDB with SQLCipher   
    pod 'FMDB/SQLCipher'   
end   
然后在终端cd到当前目录，接着运行pod install,此时编译工程会出现"Implicit declaration of function '...' is invalid in C99"的错误.   
解决方案：   
在FMDatabase.m 文件的导入头文件的位置的下方插入以下代码      
#if defined(SQLITE_HAS_CODEC)      
SQLITE_API int sqlite3_key(sqlite3 *db, const void *pKey, int nKey);      
SQLITE_API int sqlite3_rekey(sqlite3 *db, const void *pKey, int nKey);      
#endif   
效果如图：   
![SQLCipherDemo](https://img.jishux.com/jishux/2017/09/17/627c8a98192ebec5ef06ec83ecec1c30fc87e597_.jpg "修改效果图")   
    
最后，手动导入SQLCipherDemo中BG目录下的代码到自己的工程中即可,使用步骤请参考demo.   
