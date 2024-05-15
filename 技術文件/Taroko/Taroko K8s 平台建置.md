# Taroko K8S 平台建置

## 下載 Taroko K8S 壓縮檔

下載連結[請點此](https://drive.google.com/file/d/1axT84N_10R-Ftw5QL9kaB9dXqOhCvM1z/view?usp=drive_link)

## 在 Windows 執行以下命令
* 開啟檔案總管，確認壓縮檔存放位置

![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/2e3bf46d-4639-47c6-bbb8-fa81ee1f8013)

* 點選兩下進入到壓縮檔，按右鍵選擇 "複製"

![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/59d1ca54-3c02-4078-9942-9946c3f623f7)

* 在 Windows 家目錄，按右鍵選擇 "貼上"

![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/d5c38154-c3ab-4e13-922b-876928fec4f5)

* 開啟 cmd，進入 VMTK2024v1.6.7 目錄
```
cd VMTK2024v1.6.7
```
* 啟動 Taroko K8s VM
```
k start
```

## 進入 TKAdm 管理主機
* 確認 TKAdm 管理主機 IP 資訊

![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/45d4f666-d645-4aea-9bc8-d631c65d6af2)

* 使用 ssh 登入 TKAdm 管理主機
  - 帳號/密碼: bigred/bigred
```
ssh bigred@192.168.23.133
```

* 啟動 Taroko K8s
```
1m2w.sh default
```

[返回首頁](https://github.com/tarokok8s/Tarokok8s)
