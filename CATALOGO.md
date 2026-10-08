# Catálogo de scripts — Lua-Scripts

Catálogo dos scripts `.lua` para **OTClientV8 / vBot** deste repositório.

**Total: 50 scripts `.lua`**

| Categoria | Quantidade |
|---|---:|
| Packs completos | 6 |
| PvP e combate | 8 |
| Trap, Magic Wall e Wild Growth | 7 |
| Cura e suporte | 5 |
| Equipamentos (swappers) | 4 |
| Movimentação e empurrão (push) | 10 |
| Utilitários e automação | 5 |
| HUD, ícones e interface | 5 |
| **Total** | **50** |

> Observação: o README cita dois arquivos `.txt` do ElfBot NG (`ElfbotComboLeaderSD.txt` e `ElfbotComboLeaderSpell.txt`) que **não estão versionados** neste repositório, então não entram na contagem.

## Packs completos (6)

| Script | Linhas | Descrição |
|---|---:|---|
| `IconesDashPack.lua` | 271 | Pack de ícones e deslocamento: Machete/Tramontina no Wild Growth, ícones ON/OFF de CaveBot e TargetBot, Dash (bug map / map click), invisibilidade, auto mount, Utamo Vita com renovação inteligente, Auto Chase e ícones de SD Max, Paralyze Max e Avalanche Max. ✅ Pode ficar ligado **junto com o XinaCorePack.lua** (ver observação abaixo) sem duplicar ícones, macros ou hotkeys. |
| `PvPUltimatePack.lua` | 348 | Pack PvP completo com 12 módulos: MW Self Step, Anti-Push, Auto Destroy Field com Disintegrate nas flores ao redor, Wild Growth nas diagonais, SSA & Might Ring swapper, Smart Energy Ring, Fast Paralyze Cure, Combo Leader, Auto SD no target, Auto Sio em amigo, timer visual de MW no chão e HUD do alvo. Configurações centralizadas no topo do arquivo. |
| `ToolsPack.lua` | 752 | Pack de utilidades: Pick-Up de itens do chão, uso automático de itens de stamina, "Vende Tudo" com Sell Wand selecionável por arraste e Auto Follow com pathfinding multi-floor. Todos com janela de setup própria. |
| `WarPwPack.lua` | 450 | Pack de guerra com aba própria (`WarPw`): Safe SD/UE (mantém a área e só troca para SD quando um jogador próximo tem shield diferente do seu), ocultar sprites de efeitos, Auto Trap em si com Magic Wall, cura de time (UH e Sio com slider), Auto Attack Players focando o menor HP, Combo Attack com até 3 líderes, proteção de SQM com flores e coordenadas no minimapa. |
| `XinaCorePack.lua` | 3341 | ⭐ Pack completo e **autossuficiente** com aba própria (`Xina`) em 7 seções — não precisa de nenhum outro script. Na aba `Xina` ficam combate e combo (Attack Players, **ícones SDMAX / PARAMAX / AVAMAX**, Safe SD/UE, Combo Attack por míssil, Tela Limpa), trap (MW Self Step, Trapa em si, **Trapa Alvo MW** (somente Magic Wall), **MW Enemy Step** com alcance ajustável por slider, Machete — a Trapa Alvo lança runa só até 3 SQMs, para o personagem nunca andar atrás do alvo), cura (UH, Utamo, **Pot Friend**, **Sio Friend**), rings (**Energy Ring**, **Ring Invertido**), **Auto Follow** (multi-floor, abre portas fechadas no caminho) e **ícones ON/OFF de CaveBot e TargetBot** (posição fixa no canto superior esquerdo do mapa). Na aba `Tools` ficam movimentação e utilitários (**Pick-Up Items** turbinado, **Stamina Items**, **Auto Use Items**, **Vende Tudo** com runa de venda arrastável). Tudo inicia desligado. Fast Paralyze Cure, Target HUD e Force Hold MW/WG ficam apenas nos scripts avulsos. |
| `XinaPackNew.lua` | 1035 | Pack geral "+Xina" com aba própria: painel de runas, PvP de Paladin, ícones de CaveBot/TargetBot, Bug Map (DASH), ataque no alvo do líder, MW Step (`F12`), MW Target Step (`F11`), trap de MW no alvo, anti-push, potar amigo e Attack All (`Delete`). |

## PvP e combate (8)

| Script | Linhas | Descrição |
|---|---:|---|
| `AttackPlayersLowestHp.lua` | 43 | Ataca automaticamente o inimigo com **menor HP** e, em caso de empate, o mais próximo. Ignora amigos, membros de party e membros da guild. Hotkey: `Delete`. |
| `AutoDestroyField.lua` | 60 | Usa Destroy Field para remover Fire, Poison ou Energy Field embaixo do personagem e Disintegrate para remover flores nos 8 tiles ao redor. |
| `AutoSdTarget.lua` | 17 | Lança Sudden Death automaticamente no alvo atual, respeitando o mesmo andar e distância máxima de 7 SQMs. |
| `ComboAttackMissile.lua` | 62 | Combo por **detecção de míssil**: identifica o disparo (SD/runa) de até 3 líderes configuráveis e ataca o mesmo alvo no exato momento do tiro. |
| `ComboLeader.lua` | 106 | Ataque sincronizado de guild: ataca o mesmo alvo que o líder definido estiver atacando. Possui janela de setup. |
| `FastParalyzeCure.lua` | 13 | Cura o paralyze com magia no exato milissegundo em que o status é aplicado (zero-delay). |
| `NewComboLeader.lua` | 485 | Combo avançado para até 3 líderes por detecção de míssil. Pode usar **runa (SD)** ou uma **magia configurável** de forma exclusiva; inclui configuração do míssil-gatilho, alvo do líder e UE por chamada no chat. |
| `SafeSdMasFrigo.lua` | 154 | Mantém a magia de área (`exevo gran mas frigo`) e só troca para SD quando um jogador próximo tem shield diferente do personagem local. O raio de comparação é configurável no setup. |

## Trap, Magic Wall e Wild Growth (7)

| Script | Linhas | Descrição |
|---|---:|---|
| `AutoMwEnemyStep.lua` | 171 | Joga Magic Wall no SQM que o inimigo acabou de deixar, com alcance ajustável (até 7 SQMs) e ID da runa escolhidos na janela de setup. Mantenha o alcance baixo: runa usada longe demais faz o personagem andar até o SQM. |
| `FastForceHoldMwWg.lua` | 312 | Força MW e WG em posições marcadas, mantendo a parede sempre renovada. Hotkeys configuráveis (padrão `F3` para MW e `F4` para WG). |
| `MWSelfStep.lua` | 18 | Joga Magic Wall no SQM que você acabou de deixar, trapando quem está te perseguindo. |
| `MacheteWg.lua` | 37 | Corta automaticamente qualquer Wild Growth ao seu redor usando machete/tramontina. Hotkey: `F1`. |
| `TrapEmSiMw.lua` | 51 | Preenche os 8 SQMs ao redor do próprio personagem com Magic Wall. Hotkey: `NumPad5`. |
| `TrapWgDiagonals.lua` | 25 | Joga Wild Growth nas 4 diagonais do alvo para impedir a fuga em diagonal. |
| `VisualMwTimer.lua` | 45 | Escreve a contagem regressiva (em segundos) em cima de todas as Magic Walls visíveis na tela. |

## Cura e suporte (5)

| Script | Linhas | Descrição |
|---|---:|---|
| `AutoSioParty.lua` | 134 | Lança `exura sio` no amigo ferido respeitando um HP mínimo seu e o HP alvo do amigo. Com janela de setup. |
| `HealerSupportHP.lua` | 121 | Healer completo: magias de cura por faixa de HP, poções e runas de cura, além de buffs (mana shield, haste e anti-paralyze). Otimizado para não gerar lag. |
| `PotFriend.lua` | 301 | Pede poção no chat quando sua mana baixa e envia poções automaticamente para o amigo quando ele pedir no chat. Interface gráfica completa. |
| `RenewUtamoVita.lua` | 17 | Renova o `utamo vita` automaticamente ~20s antes do escudo de mana expirar. |
| `UhNoTime.lua` | 28 | Usa Ultimate Healing Rune no membro de party/guild com o menor HP, sem se curar enquanto sua vida estiver acima de 90%. |

## Equipamentos (swappers) (4)

| Script | Linhas | Descrição |
|---|---:|---|
| `EmergencyEnergyRing.lua` | 168 | **Energy Ring** avançado, com janela de setup para HP, IDs e condições. |
| `SmartEnergyRing.lua` | 26 | **Energy Ring**: equipa o anel em emergência e desequipa ao recuperar a vida. |
| `SmartRingSwapper.lua` | 149 | **Ring Invertido**: swapper de anéis com lógica invertida. Com janela de setup. |
| `SsaMightSwapper.lua` | 154 | Troca automaticamente para Stone Skin Amulet e Might Ring quando o HP cai abaixo do limite configurado. Com janela de setup. |

## Movimentação e empurrão (push) (10)

| Script | Linhas | Descrição |
|---|---:|---|
| `AntiPushGold.lua` | 23 | Joga moedas embaixo do seu pé continuamente para impedir que te empurrem. |
| `AutoChase.lua` | 10 | Mantém o modo Chase sempre ativo, sem spam de pacotes para o servidor. |
| `AutoFollow.lua` | 192 | Segue o líder com pathfinding otimizado e suporte multi-floor: escadas, buracos, corda, levitate e **abertura de portas fechadas** no caminho. |
| `AutoInvis.lua` | 11 | Mantém `utana vid` ativo automaticamente sempre que estiver fora do PZ. |
| `AutoMount.lua` | 14 | Monta automaticamente ao sair de uma zona protegida (PZ). |
| `BugMapDash.lua` | 40 | Dash pelo mapa segurando `W`, `A`, `S`, `D` ou as setas. Hotkey do ícone: `NumPad0`. |
| `FlowersXina.lua` | 40 | Planta flores nos 8 SQMs ao redor do próprio personagem automaticamente. |
| `ProtegerSqmFlores.lua` | 92 | Marca/desmarca um SQM com `F7` e planta flores nos 8 SQMs ao redor dele para impedir traps. |
| `PushMaxIcons.lua` | 65 | Empurra o alvo nas 9 direções através de ícones na tela, com suporte ao teclado numérico (`NumPad1` a `NumPad9`). |
| `PushMaxMouse.lua` | 259 | PushMax acionado pelo **scroll down** do mouse: seleciona o alvo e a direção pelo cursor e empurra automaticamente. |

## Utilitários e automação (5)

| Script | Linhas | Descrição |
|---|---:|---|
| `AutoUseItems.lua` | 290 | Fora de PZ, usa em ordem todos os itens configurados nos 15 slots e repete o ciclo a cada intervalo de 1 a 60 minutos. Se entrar em PZ durante o ciclo, pausa e continua ao sair. Com janela de setup. |
| `PickUpItems.lua` | 247 | Cata itens do chão por lista de IDs, com raio configurável e escolha do container de destino. Com janela de setup. |
| `Seller.lua` | 82 | Vende itens de uma lista usando a Sell Wand, com container editável para escolher os itens e slot arrastável para escolher a runa de venda. |
| `StaminaItems.lua` | 176 | Usa itens de regeneração de stamina automaticamente dentro de uma faixa configurável (ex.: entre 0 e 40 horas). |
| `VendeTudo.lua` | 176 | Versão otimizada do seller, com busca em tabela hash O(1) e janela de setup — vende listas grandes sem travar o client. A runa de venda é escolhida arrastando o item pro slot no Setup. |

## HUD, ícones e interface (5)

| Script | Linhas | Descrição |
|---|---:|---|
| `CaveBotTargetBotIcons.lua` | 45 | Ícones para ligar/desligar CaveBot e TargetBot, com indicador visual ON (verde) / OFF (vermelho). Posição fixa no canto superior esquerdo do mapa (CaveBot em cima, TargetBot embaixo), recolocada a cada recarregamento; também existem no XinaCorePack (seção 7) e no IconesDashPack. |
| `MinimapCoords.lua` | 27 | Exibe as coordenadas X, Y e Z no canto inferior do minimapa. |
| `StatusExpWidget.lua` | 224 | Widget compacto e arrastável com status e experiência, salvando a posição na tela entre sessões. |
| `TargetHUD.lua` | 56 | Mostra no topo central da tela o nome, tipo, HP% e distância da criatura atacada; sem alvo exibe uma mensagem de espera. |
| `TelaLimpa.lua` | 52 | Botão para ocultar textos laranjas, efeitos de magias, danos animados, mensagens do sistema e mísseis. Mensagens que contenham `says:` são preservadas. |

---

Para detalhes de instalação, hotkeys e IDs de itens, veja o [README.md](README.md).
