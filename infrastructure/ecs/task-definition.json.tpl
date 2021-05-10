[
  {
      "name": "${name}",
      "image": "${image}",
      "memory": 512,
      "essential": true,
      "environment": [
          {
              "name": "DATABASE_URL",
              "value": "postgres://root:root1234@qledger-rds.cdggwzbbaqpc.ca-central-1.rds.amazonaws.com/qledgerdb?sslmode=disable"
          },
          {
              "name": "TEST_DATABASE_URL",
              "value": "postgres://root:root1234@qledger-rds.cdggwzbbaqpc.ca-central-1.rds.amazonaws.com/qledgertestdb?sslmode=disable"
          },
          {
              "name": "MIGRATION_FILES_PATH",
              "value": "file:///go/src/github.com/RealImage/QLedger/migrations/postgres"
          },
          {
              "name": "LEDGER_AUTH_TOKEN",
              "value": "value"
          }
      ],
      "portMappings": [
          {
              "containerPort": 7000,
              "hostPort": 7000,
              "protocol": "tcp"
          }
      ]
  }
]