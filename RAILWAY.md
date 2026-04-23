# Railway 部署说明

这个仓库已经提供了根目录 `Dockerfile`，可以作为 Railway 的应用服务源。

要点：

- Railway 不会把 `docker-compose.yml` 当成单个服务直接启动。
- 如果要正常访问页面，至少需要一个数据库服务；缓存服务也建议一并创建。
- 本仓库的启动脚本会优先读取 Railway 提供的环境变量：
  - `MYSQLHOST`
  - `MYSQLPORT`
  - `MYSQLUSER`
  - `MYSQLPASSWORD`
  - `MYSQLDATABASE`
  - `REDISHOST`
  - `REDISPORT`
- 如果这些变量存在，容器会自动生成运行配置。
- 如果这些变量不存在，容器会继续使用仓库里的默认本地配置。
- 数据库没连上时，应用会在启动阶段直接退出，网页就会一直不可访问。

推荐做法：

1. 在同一个 Railway 项目里创建应用服务、数据库服务、缓存服务。
2. 让应用服务读取数据库和缓存服务自动注入的环境变量。
3. 部署后如果外链生成不对，再补 `APP_FILE_DOMAIN` 或 `PUBLIC_URL`。
