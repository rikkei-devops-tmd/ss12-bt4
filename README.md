BAI 4: KHAI BAO GITHUB SECRETS VA CAU HINH DANG NHAP CONTAINER REGISTRY

1. MUC TIEU VA BOI CANH
Khi xay dung luong CI/CD de dong goi va xuat ban Docker Image len Container Registry (nhu GitHub Container Registry - GHCR hoac Docker Hub), chung ta tuyet doi khong duoc phep hardcode mat khau hoac token vao ma nguon hay tep kich ban workflow vi ly do an ninh thong tin. GitHub Repository Secrets cung cap co che ma hoa manh me (su dung thu vien NaCl cua libsodium) de luu tru an toan cac thong tin xac thuc nhay cam.

2. QUY TRINH TAO TOKEN VA CAU HINH REPOSITORY SECRETS

2.1. Tao Personal Access Token (PAT) tren GitHub:
- Truy cap GitHub Profile -> Settings -> Developer Settings -> Personal access tokens -> Tokens (classic).
- Nhan Generate new token (classic), dat ten cho token (vi du: ghcr-token).
- Tich chon cac quyen (Scopes) can thiet:
  - write:packages (Cho phep push Container Images len GitHub Packages / GHCR).
  - read:packages (Cho phep pull Container Images).
  - delete:packages (Tuy chon, de quan ly xoa package khi can).
- Nhan Generate token va sao chep ma token duoc tao.

2.2. Khai bao Secret REGISTRY_TOKEN tren Repository:
- Truy cap vao Repository tren GitHub -> Settings -> Secrets and variables -> Actions.
- Nhan nut New repository secret.
- Dien Name: REGISTRY_TOKEN.
- Dien Secret: Dan gia tri Personal Access Token da copy o tren.
- Nhan Add secret de hoan tat luu tru duoi dang ma hoa.

3. CAU HINH GITHUB ACTIONS WORKFLOW (.github/workflows/ci.yml)
Noi dung kich ban CI tich hop buoc dang nhap Container Registry:

```yaml
name: Java Spring Boot CI (Gradle)

on:
  push:
    branches: [ "main" ]

jobs:
  test:
    name: Run Unit Tests and Registry Login
    runs-on: ubuntu-latest

    steps:
      - name: Checkout mã nguồn
        uses: actions/checkout@v5

      - name: Thiết lập môi trường Java JDK 17
        uses: actions/setup-java@v5
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Cấp quyền cho Gradle Wrapper
        run: chmod +x gradlew

      - name: Thực thi JUnit Test với Gradle
        run: ./gradlew test

      - name: Đóng gói tệp JAR với Gradle
        run: ./gradlew bootJar

      - name: Lưu trữ thành phẩm JAR Artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-jar
          path: build/libs/*.jar

      - name: Đăng nhập vào GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.REGISTRY_TOKEN }}
```

4. PHAN TICH BUOC DANG NHAP REGISTRY
- Action docker/login-action@v3: Day la action chinh thuc tu Docker giup cau hinh Docker daemon tren runner de xac thuc an toan voi cac Container Registry.
- Tham so registry: ghcr.io (Dia chi GitHub Container Registry).
- Tham so username: ${{ github.actor }} (Bien moi truong tu dong chua username cua tai khoan kich hoat workflow).
- Tham so password: ${{ secrets.REGISTRY_TOKEN }} (Lay gia tri token tu kho Repository Secrets, GitHub Actions tu dong che gia tri (masking) trong toan bo log console de ngan chan ro ri thong tin).

5. HUONG DAN KIEM TRA XAC THUC
- Day code len GitHub repository rikkei-devops-tmd/ss12-bt4.
- Mo tab Actions, chon lan chay workflow moi nhat.
- Vao chi tiet buoc Dang nhap vao GitHub Container Registry.
- Kiem tra log hien thi thong diep "Login Succeeded" va xac nhan token duoc bao mat an toan (hien thi duoi dang dau sao an danh).

