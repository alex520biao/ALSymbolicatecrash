#!/bin/sh

# 判断文件是否存在
# ${1}: 文件完整路径
# ${2}: 文件描述
# ${3}: 错误时是否弹框提醒 0 不/1 要
function fielIsExist()
{
	#入口参数
    echo "${1}" "${2}" "${3}"
	filePath=$1     
	fileName=$2    
	errorDialog=$3    
	if [ ! -f "${filePath}" ]; then 
		echo "文件不存在读取失败: ${filePath}"

#shell中调用applescript代码(EOF必须位于行首)
exec osascript <<EOF
tell application "System Events"
	set dialogResult to display dialog "此路径文件不存在读取失败: ${filePath} \n\n请检查文件路径格式(是否有特殊符号)" with title "${fileName}不存在" buttons {"ok"}
end tell
EOF
	fi 
}

# 判断文件夹是否存在
# ${1}: 文件完整路径
# ${2}: 文件描述
# ${3}: 错误时是否弹框提醒 0 不/1 要
function folderIsExist()
{
	#入口参数
    echo "${1}" "${2}" "${3}"
	folderPath=$1     
	folderName=$2    
	errorDialog=$3    
	if [ ! -d "${folderPath}" ]; then 
		echo "文件不存在读取失败: ${folderPath}"

#shell中调用applescript代码(EOF必须位于行首)
exec osascript <<EOF
tell application "System Events"
	set dialogResult to display dialog "此路径文件不存在读取失败: ${folderPath} \n\n请检查文件路径格式(是否有特殊符号)" with title "${folderPath}不存在" buttons {"ok"}
end tell
EOF
	fi 
}


#symbolicatecrash环境变量
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

#切换到sh脚本所在目录
cd "$(dirname "$0")"

#sh脚本第一个参数: 如"ONECarpool.crash"
crashPath=$1     
echo "crashPath: ${crashPath}"
fielIsExist ${crashPath} "crash文件"

#sh脚本第二个参数: 如"ONECarpool.app.dSYM"          
dsymPath=$2 
#dsym会被认为是目录删除最后一个斜杆  
dsymPath=${dsymPath%"/"} 
echo "dsymPath: ${dsymPath}"
folderIsExist ${dsymPath} "dSYM文件"

#sh脚本第三个参数: 如"ONECarpool.app"          
appPath=$3  
#dsym会被认为是目录删除最后一个斜杆  
appPath=${appPath%"/"} 
echo "appPath: ${appPath}"
folderIsExist ${appPath} "app文件"

#crash文件目录
crashDirectory=${crashPath%/*}
#crash文件全名
crashFullName=${crashPath##*/}
#crash文件名
crashName=${crashFullName%.*}
#crash文件后缀名
extension=${crashPath##*.}
echo "crashFullName: ${crashFullName}"
echo "crashName: ${crashName}"
echo "extension: ${extension}"


#dsym文件全名
dSYMFullName=${dsymPath##*/}
#dsym文件后缀名
dSYMExtension=${dsymPath##*.}
echo "dSYMFullName: ${dSYMFullName}"
echo "dSYMExtension: ${dSYMExtension}"

#app文件全名
appFullName=${appPath##*/}
#dsym文件后缀名
appExtension=${appPath##*.}
echo "appFullName: ${appFullName}"
echo "appExtension: ${appExtension}"

#复制源文件到当前工作目录
cp -f "${crashPath}" "${crashFullName}"
cp -R "${dsymPath}" "${dSYMFullName}"
cp -R "${appPath}" "${appFullName}"

#symbolCrash文件全名
symbolCrashPath=${crashDirectory}"/"${crashName}"_symbol.txt"
echo "symbolCrashPath: ${symbolCrashPath}"

#执行symbolicatecrash命令
./symbolicatecrash $crashFullName  $dSYMFullName > ${symbolCrashPath}

####清理临时文件
rm -rdf "${crashFullName}"
rm -rdf "${dSYMFullName}"
rm -rdf "${appFullName}"

#修改文件权限
chmod 777 ${symbolCrashPath}

#shell中调用applescript代码
exec osascript <<EOF
tell application "System Events"
	#语音提示
	say "哇哈哈哈哈哈 任务已完成赶快查看吧"

	set dialogResult to display dialog "symbol文件地址: ${symbolCrashPath}" with title "${crashFullName}符号化完成" buttons {"点击打开"}
	if button returned of dialogResult is "朕知道了" then
		tell application "System Events"
			#打开crash文件
			tell application "TextEdit"
				activate
				open "${symbolCrashPath}"
				print "${symbolCrashPath}" 
			end tell
		end tell
	end if
end tell
EOF



