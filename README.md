# PSnap

## Getting Started

- `curl -L https://foundry.paradigm.xyz | bash` forge 설치하기
- `forge install` contract dependencies 설치
- `yarn install` js 패키지 설치

## Environment Variables

루트 경로에 `.env` 파일을 만든 뒤, 아래를 참고해서 환경변수를 넣어주세요.

```
AMOY_RPC_URL=
AMOY_PRIVATE_KEY=
POLYGON_PRIVATE_KEY=
POLYGON_RPC_URL=
POLYGONSCAN_API_KEY= 폴리곤스캔 api 키
```

## Deploy

위의 `.env` 세팅에 새 환경변수들을 추가하신 뒤 실행해주세요.

```sh
yarn hardhat deploy --network { amoy | polygon } --tags PSnap
```

컨트랙트로 사용해주시면 됩니다. `deployed at` 뒤에 있는 hash값이 주소입니다.

## Verify

```
source .env

yarn hardhat etherscan-verify --network polygon --api-key $POLYGONSCAN_API_KEY
```
