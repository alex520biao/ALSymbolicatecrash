

###使用symbolicatecrash定位crash代码位置:
1. 创建一个临时目录;
2. 从iOS设备中导出.crash文件,打开此文件查看Version,根据此Version下载对应的.dSYM文件。
2. 目录中放入如下四个文件: `symbolicatecrash`、`xxxx.crash`、`xxxx.app.dSYM`、`xxxx.app`;

	>xxxx.app.dSYM和xxxx.app从对应版本的xxxx.xarchive文件中提取。
	
3. 查看.app文件和.app.dSYM文件的UUID,并与.crash文件中的UUID核对是否一致。
	
		dwarfdump --uuid ONECarpool.app/ONECarpool
	>UUID: 5C0CF338-4A7A-3A76-BB2D-6A9EF4B0BFFB (armv7) ONECarpool.app/ONECarpool   
	UUID: 4D6BA2A4-C9C7-34C4-B887-A8A577FA6D5C (arm64) ONECarpool.app/ONECarpool

		dwarfdump --uuid ONECarpool.app.dSYM/Contents/Resources/DWARF/ONECarpool
	
	>UUID: 5C0CF338-4A7A-3A76-BB2D-6A9EF4B0BFFB (armv7) ONECarpool.app.dSYM/Contents/Resources/DWARF/ONECarpool   
	UUID: 4D6BA2A4-C9C7-34C4-B887-A8A577FA6D5C (arm64) ONECarpool.app.dSYM/Contents/Resources/DWARF/ONECarpool

3. 终端下进入当前目录并执行如下命令:
		
		./symbolicatecrash xxxx.crash  xxxx.app.dSYM > xxxx_symbol.crash
		
4. 最后crash.text中就可以看到符号化的crash位置;


>每次打包时都要保留相应的.xarchive文件,这样才能获得app文件及dSYM文件。

###一. 查找Xcode的symbolicatecrash(符号化工具)

**在终端中输入命令搜索symbolicatecrash:**

	find /Applications/Xcode.app -name symbolicatecrash -type f
**输出结果:**
>/Applications/Xcode.app/Contents/SharedFrameworks/DTDeviceKitBase.framework/Versions/A/Resources/symbolicatecrash

###二. 错误信息
第一次使用symbolicatecrash会产生一个error，如下的错误信息
>Error: "DEVELOPER_DIR" is not defined at /usr/local/bin/symbolicatecrash line 53.    

**解决办法是在终端输入以下命令:**
	
	export DEVELOPER_DIR="/Applications/XCode.app/Contents/Developer"

>Finder-->前往-->前往文件夹,输入DEVELOPER_DIR路径可以验证此路径是否正确。	

####参考文件
* [利用.dSYM和.app文件准确定位Crash位置](http://blog.csdn.net/jinzhu117/article/details/20615991)
* [[iOS]使用symbolicatecrash分析crash文件](http://www.tuicool.com/articles/rymyEf)