# DSP Migrator

## Getting Started

- `curl -L https://foundry.paradigm.xyz | bash` forge 설치하기
- `forge install` contract dependencies 설치
- `yarn install` js 패키지 설치

## Environment Variables

루트 경로에 `.env` 파일을 만든 뒤, 아래를 참고해서 환경변수를 넣어주세요.

```
MAINNET_PRIVATE_KEY=mainnet 배포시 사용되는 비밀키
SEPOLIA_PRIVATE_KEY=sepolia 배포시 사용되는 비밀키
SEPOLIA_RPC_URL=sepolia node rpc 주소
MAINNET_RPC_URL=mainnet node rpc 주소
ETHERSCAN_API_KEY= 이더스캔 api 키
```

## Set DSP & MACH address

Migrator(예치 컨트랙트)를 배포하기 위해서는 MACH, DSP 각각 이더리움 메인넷의 컨트랙트 주소가 필요합니다.

- `deployments/mainnet/DSP.json` 파일의 `address`에 이더리움 메인넷에 배포 되어있는 DSP 토큰 컨트랙트 주소를 넣습니다.
- `deployments/mainnet/MACH.json` 파일의 `address`에 이더리움 메인넷에 배포 되어있는 MACH 토큰 컨트랙트 주소를 넣습니다.

## Deploy

```
yarn hardhat deploy --network { mainnet | sepolia }
```

위 명령어를 실행하면 아래와 같은 결과물을 확인할 수 있습니다. 아래의 결과물에서 `Migrator_Proxy` 주소를 Bootstrap
컨트랙트로 사용해주시면 됩니다. `deployed at` 뒤에 있는 hash값이 주소입니다.

```
deploying "Migrator_Implementation" (tx: 0xb7df215500a88b25d27af29c72ac3b04fa5884803ecceacaeba5483c78e4e09e)...: deployed at 0x16490Aa34bB497615371Fcd01410A31A4c600a25 with 3317346 gas
deploying "Migrator_Proxy" (tx: 0x68c984c3e6eb47fa59dda8bb92155470084ee4af26a342d3818d934e6df9e89b)...: deployed at 0xa8F2859d5Ce8542BeE7e7030ebf0B8D07df18B43 with 499828 gas
```

## Verify

```
yarn hardhat etherscan-verify --network { mainnet | sepolia }
```

## Deployments

### Sepolia

| Contracts | Address                                                                                                                       |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| DSP       | [0x7439E9Bb6D8a84dd3A23fe621A30F95403F87fB9](https://sepolia.etherscan.io/address/0x7439E9Bb6D8a84dd3A23fe621A30F95403F87fB9) |
| MACH      | [0xc21d97673B9E0B3AA53a06439F71fDc1facE393B](https://sepolia.etherscan.io/address/0xc21d97673B9E0B3AA53a06439F71fDc1facE393B) |
| Migrator  | [0x8d6B92A796ce9AE90480C502b8E0c89BF48e6B3f](https://sepolia.etherscan.io/address/0x8d6B92A796ce9AE90480C502b8E0c89BF48e6B3f) |

---
