
FROM node:22-bookworm

RUN npm install -g @kilocode/cli

WORKDIR /workspace

CMD ["kilo"]
