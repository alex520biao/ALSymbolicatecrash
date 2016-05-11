#!/bin/sh

#symbolicatecrash环境变量
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

#切换到sh脚本所在目录
cd "$(dirname "$0")"

#sh脚本第一个参数: 如"ONECarpool.crash"
crashPath=$1     

#sh脚本第二个参数: 如"ONECarpool.app.dSYM"          
dsymPath=$2   

#crash文件目录
crashDirectory=${crashPath%/*}
#crash文件全名
crashFullName=${crashPath##*/}
#crash文件名
crashName=${crashFullName%.*}
#crash文件后缀名
extension=${crashPath##*.}

#dsym文件全名
dSYMFullName=${dsymPath##*/}

#dsym文件后缀名
dSYMExtension=${dsymPath##*.}

#复制源文件到当前工作目录
cp -f "${crashPath}" "${crashFullName}"
cp -R "${dsymPath}" "${dSYMFullName}"

#symbolCrash文件全名
symbolCrashPath=${crashDirectory}"/"${crashName}"_symbol.txt"

#执行symbolicatecrash命令
echo "crashFullName: ${crashFullName}"
echo "dSYMFullName: ${dSYMFullName}"
echo "symbolCrashPath: ${symbolCrashPath}"
./symbolicatecrash $crashFullName  $dSYMFullName > ${symbolCrashPath}

####清理临时文件
rm -rdf "${crashFullName}"
rm -rdf "${dSYMFullName}"

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



