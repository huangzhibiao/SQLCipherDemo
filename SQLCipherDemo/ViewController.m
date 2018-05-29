//
//  ViewController.m
//  SQLCipherDemo
//
//  Created by biao on 2018/5/29.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import <sqlite3.h>

#define password @"123456"

#define CachePath(name) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:name]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bg_setPassword(password);
    Student* student = [Student new];
    student.name = @"标哥";
    student.age = 27;
    [student bg_save];
    
}
/**
 读取加密数据库的数据.
 */
- (IBAction)readDataAction:(id)sender {
    NSArray* arr = [Student bg_findAll:nil];
    for(Student* obj in arr){
        NSLog(@"name=%@,age=%@",obj.name,@(obj.age));
    }
}
/**
 解密数据库文件.
 将加密数据库转换为非加密数据库，用于查看加密数据.
 */
- (IBAction)decryptionAction:(id)sender {
    //加解密密码
    NSString* kDBEncryptedKey = password;
    //加密数据库文件全路径
    NSString *encryptedDBPath = CachePath(@"BGFMDB.db");
    //待生成的可查看的非加密数据库文件全路径
    NSString *plaintextDBPath = CachePath(@"dest.db");
    
    const char *sql = [[NSString stringWithFormat:@"PRAGMA key = '%@';", kDBEncryptedKey] UTF8String];
    
    const char *attachSql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY '';", plaintextDBPath] UTF8String];
    
    const char *exportSql = [[NSString stringWithFormat:@"SELECT sqlcipher_export('plaintext');"] UTF8String];
    
    const char *detachSql = [[NSString stringWithFormat:@"DETACH DATABASE plaintext;"] UTF8String];
    
    sqlite3* encrypted_DB =NULL;
    
    if(sqlite3_open([encryptedDBPath UTF8String], &encrypted_DB) ==SQLITE_OK){
        int rc;
        char *errmsg = NULL;
        rc = sqlite3_exec(encrypted_DB, sql,NULL,NULL, &errmsg);
        rc =sqlite3_exec(encrypted_DB, attachSql,NULL,NULL, &errmsg);
        rc =sqlite3_exec(encrypted_DB, exportSql,NULL,NULL, &errmsg);
        rc =sqlite3_exec(encrypted_DB, detachSql,NULL,NULL, &errmsg);
        sqlite3_close(encrypted_DB);
    }else{
        sqlite3_close(encrypted_DB);
        NSAssert1(NO,@"Failed to open database with message '%s'.", sqlite3_errmsg(encrypted_DB));
    }
}

/**
 加密数据库文件.
 将非加密数据库文件转换为加密数据库文件，用于非加密到加密的升级处理.
 */
- (IBAction)encryptionAction:(id)sender {
    //加解密密码
    NSString* kDBEncryptedKey = password;
    
    //待生成的加密数据库文件全路径
    NSString *encryptedDBPath = CachePath(@"FMDB_new.db");
    //非加密数据库文件全路径
    NSString *plainttextDBPath = CachePath(@"dest.db");
    
    const char *sql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", encryptedDBPath, kDBEncryptedKey] UTF8String];
    
    const char *exportSql = [[NSString stringWithFormat:@"SELECT sqlcipher_export('encrypted');"] UTF8String];
    
    const char *detachSql = [[NSString stringWithFormat:@"DETACH DATABASE encrypted;"] UTF8String];
    
    sqlite3 *unencrypted_DB = NULL;
    
    if(sqlite3_open([plainttextDBPath UTF8String], &unencrypted_DB) ==SQLITE_OK){
        int rc;
        char *errmsg = NULL;
        rc =sqlite3_exec(unencrypted_DB, sql,NULL,NULL, &errmsg);
        rc =sqlite3_exec(unencrypted_DB, exportSql,NULL,NULL, &errmsg);
        rc =sqlite3_exec(unencrypted_DB, detachSql,NULL,NULL, &errmsg);
        sqlite3_close(unencrypted_DB);
    }else{
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO,@"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
    }
}


@end
