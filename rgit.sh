#!/bin/bash

echo "Create a new repository on GitHub."
echo "---------------------------------"
echo -n "repository name: "
read repoName

if [ "$repoName" == "" ]; then
    repoName=$(basename `pwd`)
    ClearUpperLine "1"
    echo "repository name: $repoName"
fi

echo "visibility: "
# 特殊なキーの入力を判定する関数
CaptureSpecialKeys() {
    local SELECTION rest
    IFS= read -r -n1 -s SELECTION
    if [[ "$SELECTION" == $'\x1b' ]]; then
        read -r -n2 -s rest
        SELECTION+="$rest"
    else
        case "$SELECTION" in
            "")
                echo "Enter"
                ;;
            $'\x7f')
                echo "Backspace"
                ;;
            $'\x20')
                echo "Space"
                ;;
            *)
                read -i "$SELECTION" -e -r rest
                echo "$rest"
                ;;
        esac
        return 0
    fi

    case "$SELECTION" in
        $'\x1b\x5b\x41')
            echo "Up"
            ;;
        $'\x1b\x5b\x42')
            echo "Down"
            ;;
        $'\x1b\x5b\x43')
            echo "Right"
            ;;
        $'\x1b\x5b\x44')
            echo "Left"
            ;;
    esac
}

options=("public" "private")
cursorPoint=0

# ターミナルの標準出力をn行削除する関数
ClearUpperLine() {
    for i in $(seq 1 "$1"); do
        printf "\033[%dA" "1"
        printf "\033[2K"
    done
}

# 選択肢を出力する関数
ShowMenu() {
    for i in ${!options[@]}; do
        if [ $i -eq $cursorPoint ]; then
            printf "\e[1;31m>\e[m \e[1;4m"
        else
            echo -n "  "
        fi
        printf "${options[$i]}\e[m\n"
    done
}
ShowMenu

while true; do
    choice="$(CaptureSpecialKeys)"
    case $choice in 
        "Up")
            if [ $cursorPoint -gt 0 ]; then
                cursorPoint=$(($cursorPoint-1))
                ClearUpperLine ${#options[@]}
                ShowMenu
            fi
            ;;
        "Down")
            if [ $cursorPoint -lt 1 ]; then
                cursorPoint=$(($cursorPoint+1))
                ClearUpperLine ${#options[@]}
                ShowMenu
            fi
            ;;
        "Enter")
            ClearUpperLine $((${#options[@]}+1))
            visibility=${options[$cursorPoint]}
            echo "visibility: $visibility"
            break
            ;;
    esac
done

echo -n "This will create '$repoName' in the GitHub repository. Continue? (Y/n): "
read flag
case $flag in 
    "y"|"Y"|"")
        if [ "$flag" == "" ]; then
            ClearUpperLine "1"
            echo "This will create '$repoName' in the GitHub repository. Continue? (Y/n): Y"
        fi
        printf "\e[32m$ gh repo create $repoName --$visibility\e[m\n"
        # GitHubに新しいリポジトリを作成
        gh repo create $repoName --$visibility
        ;;
    "n"|*)
        echo "---------------------------------"
        echo "Cancel."
        return 0
        ;;
esac
echo "---------------------------------"

echo -n "Add a README file? (Y/n): "
read flag
case $flag in 
    "y"|"Y"|"")
        if [ "$flag" == "" ]; then
            ClearUpperLine "1"
            echo "Add a README file? (Y/n): Y"
        fi
        printf "\e[32m$ echo '# $repoName' >> README.md\e[m\n"
        # README.mdを作成
        echo "# $repoName" >> README.md
        ;;
    "n"|*)
        ;;
esac
echo "---------------------------------"

if [ ! -e ".gitignore" ]; then
    echo -n "Add .gitignore? (Y/n): "
    read flag
    case $flag in 
        "y"|"Y"|"")
            if [ "$flag" == "" ]; then
                ClearUpperLine "1"
                echo "Add .gitignore? (Y/n): Y"
            fi
            printf "\e[32m$ touch .gitignore\e[m\n"
            # .gitignoreを作成
            touch .gitignore
            echo -n "Edit .gitignore? (Y/n): "
            read flag
            case $flag in
                "y"|"Y"|"")
                    if [ "$flag" == "" ]; then
                        ClearUpperLine "1"
                        echo "Edit .gitignore? (Y/n): Y"
                        printf "\e[32m$ vim .gitignore\e[m\n"
                        # .gitignoreを編集
                        vim .gitignore
                    fi
                    ;;
                "n"|*)
                    ;;
            esac
            ;;
        "n"|*)
            ;;
    esac
    echo "---------------------------------"
fi

printf "\e[32m$ git init\e[m\n"
git init
printf "\e[32m$ git add .\e[m\n"
git add .
printf "\e[32m$ git commit -m 'first commit'\e[m\n"
git commit -m 'first commit'
printf "\e[32m$ git branch -M main\e[m\n"
git branch -M main
printf "\e[32m$ git remote add origin git@github.com:$(git config user.name)/$repoName.git\e[m\n"
git remote add origin git@github.com:$(git config user.name)/$repoName.git
printf "\e[32m$ git push -u origin main\e[m\n"
git push -u origin main
echo "---------------------------------"

echo "The remote connection to the GitHub repository has been completed."
