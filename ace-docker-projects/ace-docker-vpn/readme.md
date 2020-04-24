## 1-generate-conf.cmd
    生成配置文件（39.104.162.245这个ip是我当前服务器的公网IP）

## 2-generate-secret-key.cmd
    需要管理员权限
    生成密钥文件
    输入私钥密码（输入时是看不见的）：
    Enter PEM pass phrase:12345678
    再输入一遍
    Verifying - Enter PEM pass phrase:12345678
    输入一个CA名称（我这里直接回车）
    Common Name (eg: your user, host, or server name) [Easy-RSA CA]:
    输入刚才设置的私钥密码（输入完成后会再让输入一次）
    Enter pass phrase for /etc/openvpn/pki/private/ca.key:12345678
    
## 3-generate-client-certificate.cmd
    需要管理员权限
    生成客户端证书（这里的whsir改成你想要的名字）
    输入刚才设置的密码
    Enter pass phrase for /etc/openvpn/pki/private/ca.key:12345678
 
## 4.export-certificate.cmd
    导出客户端配置
    