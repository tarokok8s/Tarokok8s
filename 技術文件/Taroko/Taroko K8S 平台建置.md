# Taroko K8S 平台建置

## 下載 Taroko K8S 壓縮檔

下載連結[請點此](https://drive.google.com/file/d/1e43tgGug0gUSCRqKbSNzXiusHylG1l0W/view?usp=drive_link)

## 在 Windows 執行以下命令
* 開啟檔案總管，確認壓縮檔存放位置
![擷取_2024_04_27_16_42_33_423](https://github.com/tarokok8s/Tarokok8s/assets/62133915/52652985-8f2c-4902-bbcf-9bb34a28cb3a)

* 點選兩下進入到壓縮檔，按右鍵選擇 "複製"
![擷取_2024_04_27_16_42_39_135](https://github.com/tarokok8s/Tarokok8s/assets/62133915/465e5c7c-ff84-4e33-bd80-ee2473a9872e)

* 在 Windows 家目錄，按右鍵選擇 "貼上"
![擷取_2024_04_27_16_43_44_677](https://github.com/tarokok8s/Tarokok8s/assets/62133915/8754eb83-1da8-49cc-bafb-2e1ac13e01bd)

* 開啟 cmd，進入 VMTK2024v1.6.7 目錄
```
cd VMTK2024v1.6.7
```
* 啟動 Tariko K8S VM
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

* 啟動 Taroko K8S
```
1m2w.sh default
```

[返回首頁](https://github.com/tarokok8s/Tarokok8s)
