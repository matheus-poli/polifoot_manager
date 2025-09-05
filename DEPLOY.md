# Deploy do PoliFootball Manager no Render

Este guia explica como fazer deploy da aplicação Rails 8 no Render usando instâncias gratuitas.

## 📋 Pré-requisitos

1. Conta no [Render](https://render.com)
2. Repositório no GitHub/GitLab conectado ao Render
3. Rails Master Key configurada

## 🚀 Opções de Deploy

### Opção 1: Dual Service (Recomendado para produção)
Use `render.yaml` - Web service + Background worker separados

### Opção 2: Single Service (Econômico para free tier)
Use `render-single.yaml` - Solid Queue roda dentro do Puma

## 📦 Deploy com render.yaml

### 1. Preparar o Repositório

```bash
# Gerar Rails Master Key (se não existir)
bundle exec rails secret

# Committar os arquivos de configuração
git add render.yaml bin/render-build.sh config/queue.yml
git commit -m "Add Render deployment configuration"
git push
```

### 2. Configurar no Render Dashboard

1. Acesse [Render Dashboard](https://dashboard.render.com)
2. Clique em "New" → "Blueprint"
3. Conecte seu repositório
4. Render detectará automaticamente o `render.yaml`

### 3. Configurar Environment Variables

No Render Dashboard, configure:

```bash
RAILS_MASTER_KEY=sua_master_key_aqui
```

**Importante**: As outras variáveis são configuradas automaticamente pelo `render.yaml`

### 4. Deploy

O deploy iniciará automaticamente. Monitor o processo nos logs.

## 🔄 Deploy Alternativo (Single Service)

Para usar apenas um serviço (mais econômico):

1. Renomeie `render-single.yaml` para `render.yaml`
2. Faça o deploy normalmente

Esta opção roda Solid Queue dentro do Puma, economizando uma instância.

## 📊 Recursos dos Serviços Gratuitos

### Web Service (Free Tier)
- **RAM**: 0.5 GB
- **CPU**: Compartilhado
- **Sleep**: Após 15min de inatividade
- **Startup**: ~50s após sleep

### PostgreSQL (Free Tier)
- **Storage**: 1 GB
- **Conexões**: 97 simultâneas

### Background Worker (Free Tier)
- **RAM**: 0.5 GB
- **CPU**: Compartilhado
- **Sleep**: Após 15min de inatividade

## ⚙️ Configurações Otimizadas

### Free Tier Performance
```yaml
WEB_CONCURRENCY: 2        # Processos Puma
RAILS_MAX_THREADS: 3      # Threads por processo
JOB_CONCURRENCY: 1        # Processos Solid Queue
```

### WebSockets e Real-time
- **Solid Cable**: Configurado para usar PostgreSQL
- **Turbo Streams**: Funciona nativamente
- **ActionCable**: Suporte completo a WebSockets

## 🔧 Troubleshooting

### Build Errors
```bash
# Verificar logs de build no Render Dashboard
# Problemas comuns:
# 1. Rails Master Key faltando
# 2. Dependências não instaladas
# 3. Assets não compilados
```

### Database Issues
```bash
# Migrations não executaram
# Solução: Re-deploy ou executar manualmente via Render Shell
bundle exec rails db:migrate RAILS_ENV=production
```

### Memory Issues (Free Tier)
```bash
# Ajustar configurações em render.yaml:
WEB_CONCURRENCY: 1        # Reduzir processos
RAILS_MAX_THREADS: 2      # Reduzir threads
```

## 📱 Monitoramento

### Health Check
Endpoint: `https://seu-app.onrender.com/up`

### Logs
- Web Service: Render Dashboard → Service → Logs
- Background Worker: Render Dashboard → Worker → Logs

### Jobs Queue
- Solid Queue roda via PostgreSQL
- Monitor via logs do worker service

## 🔄 Updates e Manutenção

### Deploy Automático
- Push no branch principal = deploy automático
- Render executa `bin/render-build.sh` automaticamente

### Migrations
- Executadas automaticamente no build
- Includes: primary, cache, queue, cable databases

### Rollback
- Via Render Dashboard → Service → Deploys
- Ou re-deploy do commit anterior

## 💡 Dicas de Economia

1. **Use Single Service** para projetos pequenos
2. **Monitor usage** no Render Dashboard  
3. **Configure sleep** adequadamente para sua use case
4. **Otimize queries** para reduzir uso de CPU/RAM

## 🔗 Links Úteis

- [Render Documentation](https://render.com/docs)
- [Rails 8 + Solid Queue](https://github.com/rails/solid_queue)
- [Render Blueprint Reference](https://render.com/docs/blueprint-spec)