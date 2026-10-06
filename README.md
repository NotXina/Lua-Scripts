# Lua-Scripts

Coleção de scripts em Lua para **OTClientV8 (OTCv8)** com **vBot**, focados em PvP, suporte, automação e interface (HUD).

> Testado em **OTCv8 3.2 / vBot 4.8**

---

## Índice

- [Como instalar](#como-instalar)
- [Packs completos](#-packs-completos)
- [PvP e combate](#-pvp-e-combate)
- [Trap, Magic Wall e Wild Growth](#-trap-magic-wall-e-wild-growth)
- [Cura e suporte](#-cura-e-suporte)
- [Equipamentos (swappers)](#-equipamentos-swappers)
- [Movimentação e empurrão (push)](#-movimentação-e-empurrão-push)
- [Utilitários e automação](#-utilitários-e-automação)
- [HUD, ícones e interface](#-hud-ícones-e-interface)
- [Hotkeys padrão](#hotkeys-padrão)
- [Observações](#observações)

---

## Como instalar

1. Abra o OTClientV8 com o **vBot** carregado.
2. Vá em `Bot` → selecione o perfil → botão **Edit** (ou `Add new script`).
3. Crie um novo script, cole o conteúdo do arquivo `.lua` desejado e salve.
4. Alternativamente, copie o arquivo `.lua` para a pasta de scripts do vBot
   (`otclientv8/bot/<seu_perfil>/`) e recarregue o bot.
5. Ajuste os **IDs de itens**, **nomes de líderes/amigos** e **hotkeys** no topo de cada
   script (ou pela janela de *Setup*, quando o script tiver uma).

### Script para ElfBot NG

O arquivo **`ElfbotComboLeader.txt`** é uma versão para ElfBot NG com três líderes,
modo de combo por SD ou por magia configurável e UE opcional por mensagem da guild.
Ele usa o Navigation Server para transportar o alvo do líder, pois as hotkeys do ElfBot
não possuem um callback `onMissile` equivalente ao `onMissle` do vBot.

Uso rápido:

1. Abra o arquivo e altere `Leader1`, `Leader2`, `Leader3`, `$cl_mode` (`sd` ou
   `spell`), `$cl_spell` e as duas magias de UE.
2. Cole as três linhas em **Hotkeys → Persistent** nos personagens seguidores.
3. Conecte todos os clientes ao mesmo Navigation Server.
4. No líder, use uma hotkey no momento do disparo:
   `navsay 'combo $target.name'`
5. A mensagem de gatilho da UE deve ser enviada no **Guild Chat**. O script verifica
   `$cl_ue_msg.isguild` e lança `$cl_my_ue` no personagem seguidor; `say` continua sendo
   usado na resposta porque é ele que lança a magia no jogo.
6. Para SD, também é possível usar o Aimbot nativo do ElfBot: informe os três nomes
   em **Aim Leaders** separados por vírgulas e selecione **Lock on leader's target**,
   **Trace shots**, **Execute automatically** e **Attack + SD Rune**. Nesse caso o
   Aimbot já detecta o tiro de SD e o arquivo não é necessário para o combo de SD.

No arquivo, `$cl_mode 'sd'` executa `sd target`; troque para `$cl_mode 'spell'`
para atacar o alvo recebido e dizer `$cl_spell`. O script personalizado por
Navigation é necessário para usar uma magia arbitrária como resposta, já que o
ElfBot não expõe o evento do míssil às hotkeys. Sem Navigation, substitua `navsay`
por `guildsay` e mantenha `$cl_msg.isnavi` somente se o alvo continuar vindo pelo
Navigation; para o comando pelo Guild Chat, use `$cl_msg.isguild`. A magia de UE
continua usando `say`, pois ela precisa ser lançada no canal padrão do jogo.

---

## 📦 Packs completos

Arquivos que reúnem vários módulos em um só script, geralmente com aba própria e janelas de configuração.

| Script | Descrição |
|---|---|
| **XinaCorePack.lua** | ⭐ Pack completo com aba própria (`Xina`) em 7 seções. Inclui combate e combo (Attack Players, Auto SD, **ícones SDMAX / PARAMAX / AVAMAX**, Safe SD/UE, Combo Attack por míssil, Tela Limpa), trap (MW Self Step, Trapa em si, **Trapa Alvo WG/MW**, **Force Hold MW/WG**, **MW Enemy Step**, Machete), cura (UH, Utamo, **Pot Friend**, **Sio Friend**), rings (**Energy Ring**, **Ring Invertido**), movimentação e utilitários (**Pick-Up Items**, **Stamina Items**, **Auto Use Items**, **Vende Tudo**) e HUD. Também traz ícones ON/OFF de CaveBot e TargetBot; tudo inicia desligado. |
| **PvPUltimatePack.lua** | Pack PvP completo com 12 módulos: MW Self Step, Anti-Push, Auto Destroy Field com Disintegrate nas flores ao redor, Wild Growth nas diagonais, SSA & Might Ring swapper, Smart Energy Ring, Fast Paralyze Cure, Combo Leader, Auto SD no target, Auto Sio em amigo, timer visual de MW no chão e HUD do alvo. Configurações centralizadas no topo do arquivo. |
| **WarPwPack.lua** | Pack de guerra com aba própria (`WarPw`): Safe SD/UE (mantém a área e só troca para SD quando um jogador próximo tem shield diferente do seu), ocultar sprites de efeitos, Auto Trap em si com Magic Wall, cura de time (UH e Sio com slider), Auto Attack Players focando o menor HP, Combo Attack com até 3 líderes, proteção de SQM com flores e coordenadas no minimapa. |
| **ToolsPack.lua** | Pack de utilidades: Pick-Up de itens do chão, uso automático de itens de stamina, "Vende Tudo" com Sell Wand e Auto Follow com pathfinding multi-floor. Todos com janela de setup própria. |
| **IconesDashPack.lua** | Pack de ícones e deslocamento: Machete/Tramontina no Wild Growth, ícones ON/OFF de CaveBot e TargetBot, Dash (bug map / map click), invisibilidade, auto mount, Utamo Vita com renovação inteligente, Auto Chase e ícones de SD Max, Paralyze Max e Avalanche Max. ✅ Pode ficar ligado **junto com o XinaCorePack.lua** (ver observação abaixo) sem duplicar ícones, macros ou hotkeys. |
| **XinaPackNew.lua** | Pack geral "+Xina" com aba própria: painel de runas, PvP de Paladin, ícones de CaveBot/TargetBot, Bug Map (DASH), ataque no alvo do líder, MW Step (`F12`), MW Target Step (`F11`), trap de MW no alvo, anti-push, potar amigo e Attack All (`Delete`). |

---

## ⚔️ PvP e combate

| Script | Descrição |
|---|---|
| **AttackPlayersLowestHp.lua** | Ataca automaticamente o inimigo com **menor HP** e, em caso de empate, o mais próximo. Ignora amigos, membros de party e membros da guild. Hotkey: `Delete`. |
| **ComboLeader.lua** | Ataque sincronizado de guild: ataca o mesmo alvo que o líder definido estiver atacando. Possui janela de setup. |
| **NewComboLeader.lua** | Combo avançado para até 3 líderes por detecção de míssil. Pode usar **runa (SD)** ou uma **magia configurável** de forma exclusiva; inclui configuração do míssil-gatilho, alvo do líder e UE por chamada no chat. |
| **ComboAttackMissile.lua** | Combo por **detecção de míssil**: identifica o disparo (SD/runa) de até 3 líderes configuráveis e ataca o mesmo alvo no exato momento do tiro. |
| **AutoSdTarget.lua** | Lança Sudden Death automaticamente no alvo atual, respeitando o mesmo andar e distância máxima de 7 SQMs. |
| **SafeSdMasFrigo.lua** | Mantém a magia de área (`exevo gran mas frigo`) e só troca para SD quando um jogador próximo tem shield diferente do personagem local. O raio de comparação é configurável no setup. |
| **AutoDestroyField.lua** | Usa Destroy Field para remover Fire, Poison ou Energy Field embaixo do personagem e Disintegrate para remover flores nos 8 tiles ao redor. |
| **FastParalyzeCure.lua** | Cura o paralyze com magia no exato milissegundo em que o status é aplicado (zero-delay). |

---

## 🧱 Trap, Magic Wall e Wild Growth

| Script | Descrição |
|---|---|
| **MWSelfStep.lua** | Joga Magic Wall no SQM que você acabou de deixar, trapando quem está te perseguindo. |
| **AutoMwEnemyStep.lua** | Joga Magic Wall no próximo passo do inimigo, prevendo o movimento. Com janela de setup para o ID da runa. |
| **TrapEmSiMw.lua** | Preenche os 8 SQMs ao redor do próprio personagem com Magic Wall. Hotkey: `NumPad5`. |
| **TrapWgDiagonals.lua** | Joga Wild Growth nas 4 diagonais do alvo para impedir a fuga em diagonal. |
| **FastForceHoldMwWg.lua** | Força MW e WG em posições marcadas, mantendo a parede sempre renovada. Hotkeys configuráveis (padrão `F3` para MW e `F4` para WG). |
| **MacheteWg.lua** | Corta automaticamente qualquer Wild Growth ao seu redor usando machete/tramontina. Hotkey: `F1`. |
| **VisualMwTimer.lua** | Escreve a contagem regressiva (em segundos) em cima de todas as Magic Walls visíveis na tela. |

---

## 💚 Cura e suporte

| Script | Descrição |
|---|---|
| **HealerSupportHP.lua** | Healer completo: magias de cura por faixa de HP, poções e runas de cura, além de buffs (mana shield, haste e anti-paralyze). Otimizado para não gerar lag. |
| **UhNoTime.lua** | Usa Ultimate Healing Rune no membro de party/guild com o menor HP, sem se curar enquanto sua vida estiver acima de 90%. |
| **AutoSioParty.lua** | Lança `exura sio` no amigo ferido respeitando um HP mínimo seu e o HP alvo do amigo. Com janela de setup. |
| **PotFriend.lua** | Pede poção no chat quando sua mana baixa e envia poções automaticamente para o amigo quando ele pedir no chat. Interface gráfica completa. |
| **RenewUtamoVita.lua** | Renova o `utamo vita` automaticamente ~20s antes do escudo de mana expirar. |

---

## 💍 Equipamentos (swappers)

| Script | Descrição |
|---|---|
| **SsaMightSwapper.lua** | Troca automaticamente para Stone Skin Amulet e Might Ring quando o HP cai abaixo do limite configurado. Com janela de setup. |
| **SmartRingSwapper.lua** | **Ring Invertido**: swapper de anéis com lógica invertida. Com janela de setup. |
| **SmartEnergyRing.lua** | **Energy Ring**: equipa o anel em emergência e desequipa ao recuperar a vida. |
| **EmergencyEnergyRing.lua** | **Energy Ring** avançado, com janela de setup para HP, IDs e condições. |

---

## 🏃 Movimentação e empurrão (push)

| Script | Descrição |
|---|---|
| **AutoFollow.lua** | Segue o líder com pathfinding otimizado e suporte multi-floor: escadas, buracos, corda e levitate. |
| **AutoChase.lua** | Mantém o modo Chase sempre ativo, sem spam de pacotes para o servidor. |
| **AutoMount.lua** | Monta automaticamente ao sair de uma zona protegida (PZ). |
| **BugMapDash.lua** | Dash pelo mapa segurando `W`, `A`, `S`, `D` ou as setas. Hotkey do ícone: `NumPad0`. |
| **PushMaxIcons.lua** | Empurra o alvo nas 9 direções através de ícones na tela, com suporte ao teclado numérico (`NumPad1` a `NumPad9`). |
| **PushMaxMouse.lua** | PushMax acionado pelo **scroll down** do mouse: seleciona o alvo e a direção pelo cursor e empurra automaticamente. |
| **AntiPushGold.lua** | Joga moedas embaixo do seu pé continuamente para impedir que te empurrem. |
| **ProtegerSqmFlores.lua** | Marca/desmarca um SQM com `F7` e planta flores nos 8 SQMs ao redor dele para impedir traps. |
| **FlowersXina.lua** | Planta flores nos 8 SQMs ao redor do próprio personagem automaticamente. |
| **AutoInvis.lua** | Mantém `utana vid` ativo automaticamente sempre que estiver fora do PZ. |

---

## 🧰 Utilitários e automação

| Script | Descrição |
|---|---|
| **PickUpItems.lua** | Cata itens do chão por lista de IDs, com raio configurável e escolha do container de destino. Com janela de setup. |
| **Seller.lua** | Vende itens de uma lista usando a Sell Wand, com container editável para escolher os itens. |
| **VendeTudo.lua** | Versão otimizada do seller, com busca em tabela hash O(1) e janela de setup — vende listas grandes sem travar o client. |
| **StaminaItems.lua** | Usa itens de regeneração de stamina automaticamente dentro de uma faixa configurável (ex.: entre 0 e 40 horas). |
| **AutoUseItems.lua** | Fora de PZ, usa em ordem todos os itens configurados nos 15 slots e repete o ciclo a cada intervalo de 1 a 60 minutos. Se entrar em PZ durante o ciclo, pausa e continua ao sair. Com janela de setup. |

---

## 🖥️ HUD, ícones e interface

| Script | Descrição |
|---|---|
| **TargetHUD.lua** | Mostra no topo central da tela o nome, tipo, HP% e distância da criatura atacada; sem alvo exibe uma mensagem de espera. |
| **StatusExpWidget.lua** | Widget compacto e arrastável com status e experiência, salvando a posição na tela entre sessões. |
| **MinimapCoords.lua** | Exibe as coordenadas X, Y e Z no canto inferior do minimapa. |
| **CaveBotTargetBotIcons.lua** | Ícones arrastáveis para ligar/desligar CaveBot e TargetBot, com indicador visual ON (verde) / OFF (vermelho). Esses ícones também ficam dentro do XinaCorePack. |
| **TelaLimpa.lua** | Botão para ocultar textos laranjas, efeitos de magias, danos animados, mensagens do sistema e mísseis. Mensagens que contenham `says:` são preservadas. |

### Como usar o Target HUD

O Target HUD aparece no topo central da tela. Ele começa mostrando `TARGET HUD: nenhum alvo`
para confirmar que está carregado e, ao atacar uma criatura, passa a mostrar nome, tipo, HP e
distância. Ele acompanha o alvo retornado pelo ataque atual (`g_game.getAttackingCreature()`),
portanto não mostra informações de uma criatura apenas por passar o mouse sobre ela. No painel
`Xina`, deixe a macro **Target HUD** ligada.

---

## Hotkeys padrão

| Tecla | Ação | Script |
|---|---|---|
| `Delete` | Attack Players / Attack All | AttackPlayersLowestHp, WarPwPack, XinaPackNew, XinaCorePack |
| `F1` | Machete no Wild Growth | MacheteWg, IconesDashPack, XinaCorePack |
| `F3` / `F4` | Marcar posição de MW / WG | FastForceHoldMwWg, XinaCorePack |
| `F7` | Marcar/desmarcar SQM protegido por flores | ProtegerSqmFlores, WarPwPack |
| `F11` | MW no SQM do alvo | XinaPackNew |
| `F12` | MW no SQM anterior (Mwall Step) | XinaPackNew |
| `NumPad0` | Dash / Bug Map | BugMapDash, IconesDashPack, XinaPackNew, XinaCorePack |
| `NumPad5` | Trapa em si com Magic Wall | TrapEmSiMw, WarPwPack, XinaCorePack |
| `NumPad1`–`NumPad9` | Empurrar alvo nas 9 direções | PushMaxIcons |

---

## Observações

- Os **IDs de itens e runas** seguem o padrão do Tibia global; em OTServs customizados pode ser
  necessário ajustá-los no topo de cada script. No XinaCorePack, os ícones usam SD `3155`,
  Paralyze `3165` e Avalanche `3161`.
- Scripts marcados com *Setup Window* criam uma janela de configuração própria e salvam os
  valores em `storage`, persistindo entre sessões.
- Vários scripts usam o mesmo módulo (ex.: `MWSelfStep` também existe dentro de
  `PvPUltimatePack`). Evite carregar o script avulso e o pack ao mesmo tempo para não
  duplicar macros e hotkeys.
- **Exceção:** `IconesDashPack.lua` e `XinaCorePack.lua` foram feitos para funcionar
  ligados ao mesmo tempo. Os dois compartilham os módulos de Machete, ícones de
  CaveBot/TargetBot, Dash, Invis, Mount, Utamo e Chase através de uma trava global
  (`xinaSharedIcons` / `claimSharedIcon`): o primeiro script a carregar cria o
  ícone/macro/hotkey daquele módulo, e o outro detecta e pula a criação — evitando
  ícone duplicado na tela, hotkey duplicada (ex.: `F1` e `NumPad0`) e o dobro de
  timers rodando ao mesmo tempo (menos lag). Não importa a ordem em que os dois são
  carregados.
- Use por sua conta e risco: automação pode violar as regras do servidor em que você joga.
