"""
Gerador de imagens para a Aula 12 — Rollback Strategies e AIOps
Estilo: fundo branco, azul #0D2B45, laranja #F58220, Segoe UI / DejaVu Sans
"""
from PIL import Image, ImageDraw, ImageFont
import os, textwrap

OUT = os.path.join(os.path.dirname(__file__), "aula-12")
W, H = 1280, 720

# ── Paleta ──────────────────────────────────────────────────────────────────
AZUL      = "#0D2B45"
AZUL2     = "#1B3A5C"
LARANJA   = "#F58220"
VERDE     = "#1A7F37"
VERMELHO  = "#CF222E"
CINZA_BG  = "#F5F7FA"
CINZA     = "#555555"
BRANCO    = "#FFFFFF"
AZUL_CL   = "#2E86C1"

# ── Fontes ───────────────────────────────────────────────────────────────────
def font(size, bold=False):
    paths = [
        f"/usr/share/fonts/truetype/dejavu/DejaVuSans{'-Bold' if bold else ''}.ttf",
        f"/usr/share/fonts/truetype/liberation/LiberationSans{'-Bold' if bold else '-Regular'}.ttf",
        f"/usr/share/fonts/truetype/ubuntu/Ubuntu{'-B' if bold else '-R'}.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

def save(img, name):
    img.save(os.path.join(OUT, name))
    print(f"  ✓ {name}")

def new_img():
    img = Image.new("RGB", (W, H), BRANCO)
    return img, ImageDraw.Draw(img)

def title(d, text, y=38, color=AZUL):
    f = font(44, bold=True)
    d.text((W//2, y), text, fill=color, font=f, anchor="mt")

def subtitle(d, text, y, color=AZUL2):
    f = font(26, bold=False)
    d.text((W//2, y), text, fill=color, font=f, anchor="mt")

def label(d, text, x, y, size=20, color=CINZA, bold=False, anchor="mm"):
    d.text((x, y), text, fill=color, font=font(size, bold), anchor=anchor)

def rect(d, x1, y1, x2, y2, fill, radius=10, outline=None, width=2):
    d.rounded_rectangle([x1, y1, x2, y2], radius=radius, fill=fill,
                        outline=outline, width=width)

def arrow_h(d, x1, x2, y, color=AZUL, width=3):
    d.line([(x1, y), (x2, y)], fill=color, width=width)
    d.polygon([(x2, y), (x2-12, y-7), (x2-12, y+7)], fill=color)

def arrow_v(d, x, y1, y2, color=AZUL, width=3):
    d.line([(x, y1), (x, y2)], fill=color, width=width)
    d.polygon([(x, y2), (x-7, y2-12), (x+7, y2-12)], fill=color)


# ════════════════════════════════════════════════════════════════════════════
# rd001 — Incidente TechNova: anatomia do MTTR
# ════════════════════════════════════════════════════════════════════════════
def rd001():
    img, d = new_img()
    title(d, "Anatomia do Incidente — MTTR")

    # linha do tempo
    TY = 290
    X0, X1 = 80, 1200
    d.line([(X0, TY), (X1, TY)], fill=AZUL, width=4)
    arrow_h(d, X1-4, X1+10, TY, color=AZUL, width=4)

    # marcos
    marcos = [
        (X0,   "17h45",  "Deploy\nv2.8",    AZUL2),
        (380,  "18h02",  "Usuários\nreclamam", VERMELHO),
        (700,  "18h17",  "Engenheiro\nonline",  LARANJA),
        (1100, "18h20",  "Rollback\nconcluído", VERDE),
    ]
    for x, hora, evento, cor in marcos:
        d.line([(x, TY-18), (x, TY+18)], fill=cor, width=3)
        label(d, hora, x, TY-38, size=22, color=cor, bold=True, anchor="mm")
        for i, line in enumerate(evento.split("\n")):
            label(d, line, x, TY+50+i*28, size=20, color=cor, anchor="mm")

    # setas TTD e TTR
    # TTD: deploy → reclamação
    d.line([(X0, TY+135), (380, TY+135)], fill=AZUL_CL, width=3)
    arrow_h(d, 376, 380, TY+135, color=AZUL_CL)
    rect(d, 130, TY+120, 335, TY+155, fill=AZUL_CL, radius=8)
    label(d, "TTD = 17 min", 230, TY+137, size=18, color=BRANCO, bold=True, anchor="mm")

    # TTR: reclamação → rollback
    d.line([(380, TY+170), (1100, TY+170)], fill=LARANJA, width=3)
    arrow_h(d, 1096, 1100, TY+170, color=LARANJA)
    rect(d, 580, TY+155, 870, TY+190, fill=LARANJA, radius=8)
    label(d, "TTR = 18 min", 725, TY+172, size=18, color=BRANCO, bold=True, anchor="mm")

    # MTTR total
    d.line([(X0, TY+215), (1100, TY+215)], fill=VERMELHO, width=4)
    arrow_h(d, 1096, 1100, TY+215, color=VERMELHO, width=4)
    rect(d, 450, TY+198, 750, TY+235, fill=VERMELHO, radius=8)
    label(d, "MTTR = 35 min", 600, TY+216, size=20, color=BRANCO, bold=True, anchor="mm")

    save(img, "rd001.png")

# ════════════════════════════════════════════════════════════════════════════
# rd002 — Rollback por estratégia (tabela visual)
# ════════════════════════════════════════════════════════════════════════════
def rd002():
    img, d = new_img()
    title(d, "Rollback por Estratégia de Deploy")

    estrategias = [
        ("Recreate",   "STOP novo → START anterior",  "Durante o processo",  VERMELHO),
        ("Blue-Green", "ALB → ambiente anterior",      "Zero downtime ✓",     VERDE),
        ("Canary",     "Remove canary → 100% stable",  "Zero downtime ✓",     VERDE),
    ]

    XL = 60
    cols = [60, 320, 740, 1050]
    headers = ["Estratégia", "Mecanismo de Rollback", "Downtime"]
    YH = 130
    rect(d, XL, YH, W-XL, YH+48, fill=AZUL2, radius=8)
    for i, h in enumerate(headers):
        label(d, h, cols[i]+10, YH+24, size=22, color=BRANCO, bold=True, anchor="lm")

    for row, (nome, mecanismo, downtime, cor_dt) in enumerate(estrategias):
        Y = YH + 60 + row * 120
        bg = CINZA_BG if row % 2 == 0 else BRANCO
        rect(d, XL, Y, W-XL, Y+100, fill=bg, radius=8, outline="#E0E0E0", width=1)

        # badge estratégia
        rect(d, cols[0]+5, Y+20, cols[0]+220, Y+70, fill=AZUL, radius=8)
        label(d, nome, cols[0]+115, Y+45, size=24, color=BRANCO, bold=True, anchor="mm")

        label(d, mecanismo, cols[1]+10, Y+45, size=21, color=AZUL2, anchor="lm")

        # badge downtime
        rect(d, cols[2]+10, Y+22, cols[2]+260, Y+72, fill=cor_dt, radius=8)
        label(d, downtime, cols[2]+140, Y+47, size=19, color=BRANCO, bold=True, anchor="mm")

    # nota ECR
    rect(d, XL, 530, W-XL, 590, fill="#FFF8E8", radius=8, outline=LARANJA, width=2)
    label(d, "Todos dependem de imagens versionadas no Amazon ECR — rollback = docker pull <tag-anterior>",
          W//2, 560, size=20, color=AZUL2, bold=False, anchor="mm")

    save(img, "rd002.png")

# ════════════════════════════════════════════════════════════════════════════
# rd003 — Padrão Expand-Contract (3 fases)
# ════════════════════════════════════════════════════════════════════════════
def rd003():
    img, d = new_img()
    title(d, "Padrão Expand-Contract — Migrações Reversíveis")

    fases = [
        ("1. EXPAND",      "#2E86C1", "Adiciona coluna nova\nMantém coluna antiga\nDua versões convivem"),
        ("2. TRANSIÇÃO",   LARANJA,   "App lê da nova coluna\nAinda escreve nas duas\nRollback ainda seguro ✓"),
        ("3. CONTRACT",    VERDE,     "Remove coluna antiga\nSomente quando v.anterior\nfor aposentada"),
    ]

    XS = [60, 460, 860]
    XE = [420, 820, 1220]
    Y1 = 150

    for i, (fase, cor, texto) in enumerate(fases):
        # caixa
        rect(d, XS[i], Y1, XE[i], Y1+380, fill=cor, radius=14)
        label(d, fase, (XS[i]+XE[i])//2, Y1+40, size=27, color=BRANCO, bold=True, anchor="mm")

        # linhas de texto
        for j, linha in enumerate(texto.split("\n")):
            label(d, linha, (XS[i]+XE[i])//2, Y1+110+j*52,
                  size=21, color=BRANCO, anchor="mm")

        # seta entre fases
        if i < 2:
            arrow_h(d, XE[i]+4, XS[i+1]-4, Y1+190, color=AZUL, width=4)

    # aviso embaixo
    rect(d, 60, 575, W-60, 630, fill="#FFF3CD", radius=8, outline=LARANJA, width=2)
    label(d, "⏰  Entre EXPAND e CONTRACT: dias ou semanas — nunca remova colunas no mesmo deploy que muda o código",
          W//2, 602, size=19, color=AZUL2, anchor="mm")

    save(img, "rd003.png")

# ════════════════════════════════════════════════════════════════════════════
# rd004 — Feature Flags: com e sem
# ════════════════════════════════════════════════════════════════════════════
def rd004():
    img, d = new_img()
    title(d, "Feature Flags — Rollback Sem Redeploy")

    # Lado SEM flag
    rect(d, 40, 130, 590, 450, fill="#FFF0F0", radius=14, outline=VERMELHO, width=2)
    label(d, "❌  SEM Feature Flag", 315, 165, size=26, color=VERMELHO, bold=True, anchor="mm")

    passos_sem = ["bug detectado", "novo commit", "CI/CD executa", "deploy concluído"]
    cores_sem  = [VERMELHO, AZUL2, AZUL2, AZUL2]
    for i, (p, c) in enumerate(zip(passos_sem, cores_sem)):
        bx = 80 + i*120
        rect(d, bx, 220, bx+100, 280, fill=c, radius=8)
        label(d, p, bx+50, 250, size=15, color=BRANCO, bold=True, anchor="mm")
        if i < 3:
            arrow_h(d, bx+100, bx+120, 250, color=AZUL)

    label(d, "⏱  10 – 15 minutos para resolver", 315, 350, size=22, color=VERMELHO, bold=True, anchor="mm")
    label(d, "Pipeline completo a cada correção", 315, 395, size=19, color=CINZA, anchor="mm")

    # Lado COM flag
    rect(d, 640, 130, W-40, 450, fill="#F0FFF4", radius=14, outline=VERDE, width=2)
    label(d, "✅  COM Feature Flag", 965, 165, size=26, color=VERDE, bold=True, anchor="mm")

    passos_com = ["bug detectado", "desliga a flag"]
    for i, p in enumerate(passos_com):
        bx = 680 + i*200
        rect(d, bx, 220, bx+160, 280, fill=VERDE, radius=8)
        label(d, p, bx+80, 250, size=16, color=BRANCO, bold=True, anchor="mm")
        if i < 1:
            arrow_h(d, bx+160, bx+200, 250, color=VERDE)

    label(d, "⚡  < 1 segundo para resolver", 965, 350, size=22, color=VERDE, bold=True, anchor="mm")
    label(d, "Sem novo commit, sem pipeline", 965, 395, size=19, color=CINZA, anchor="mm")

    # Tipos de flag
    rect(d, 40, 480, W-40, 640, fill=CINZA_BG, radius=10, outline="#D0D0D0", width=1)
    label(d, "Tipos de Flag:", 80, 510, size=22, color=AZUL2, bold=True, anchor="lm")
    tipos = [("Release", "feature em dev"), ("Ops (kill switch)", "emergências"), ("Experiment", "A/B testing"), ("Permission", "feature premium")]
    for i, (tipo, desc) in enumerate(tipos):
        bx = 80 + i * 290
        rect(d, bx, 535, bx+260, 620, fill=AZUL, radius=8)
        label(d, tipo, bx+130, 560, size=18, color=LARANJA, bold=True, anchor="mm")
        label(d, desc,  bx+130, 595, size=16, color=BRANCO, anchor="mm")

    save(img, "rd004.png")

# ════════════════════════════════════════════════════════════════════════════
# rd005 — Rollback automático no pipeline
# ════════════════════════════════════════════════════════════════════════════
def rd005():
    img, d = new_img()
    title(d, "Rollback Automático no Pipeline CD")

    # fluxo principal
    etapas = [
        (120,  "Deploy\nv2.8",           AZUL2),
        (360,  "Janela de\nobservação",   LARANJA),
        (600,  "Health\nChecks",          AZUL_CL),
        (840,  "Validação\nALB",          AZUL_CL),
    ]
    Y_FLOW = 220
    for i, (x, label_txt, cor) in enumerate(etapas):
        rect(d, x-80, Y_FLOW-50, x+80, Y_FLOW+50, fill=cor, radius=12)
        for j, l in enumerate(label_txt.split("\n")):
            label(d, l, x, Y_FLOW-15+j*32, size=20, color=BRANCO, bold=True, anchor="mm")
        if i < len(etapas)-1:
            arrow_h(d, x+80, x+160, Y_FLOW, color=AZUL, width=3)

    # diamante de decisão
    DX, DY = 1080, 220
    pts = [(DX, DY-55), (DX+70, DY), (DX, DY+55), (DX-70, DY)]
    d.polygon(pts, fill=VERDE, outline=AZUL2, width=2)
    label(d, "OK?", DX, DY, size=22, color=BRANCO, bold=True, anchor="mm")
    arrow_h(d, 920, 1010, 220, color=AZUL, width=3)

    # caminho SIM → deploy concluído
    arrow_h(d, 1150, 1220, 220, color=VERDE, width=3)
    rect(d, 1220, 170, W-30, 270, fill=VERDE, radius=10)
    label(d, "Deploy", 1263, 210, size=19, color=BRANCO, bold=True, anchor="lm")
    label(d, "Concluído ✓", 1263, 240, size=19, color=BRANCO, anchor="lm")

    # caminho NÃO → rollback
    arrow_v(d, DX, DY+55, DY+130, color=VERMELHO, width=3)
    rect(d, DX-200, DY+130, DX+200, DY+230, fill=VERMELHO, radius=10)
    label(d, "ROLLBACK AUTOMÁTICO", DX, DY+180, size=22, color=BRANCO, bold=True, anchor="mm")

    # passos rollback
    passos_rb = ["pull tag anterior\n(ECR)", "notifica\nequipe", "marca pipeline\nFAILED"]
    for i, p in enumerate(passos_rb):
        bx = DX - 320 + i * 240
        rect(d, bx-90, DY+280, bx+90, DY+380, fill=AZUL2, radius=8)
        for j, l in enumerate(p.split("\n")):
            label(d, l, bx, DY+310+j*38, size=17, color=BRANCO, anchor="mm")
        if i < 2:
            arrow_h(d, bx+90, bx+150, DY+330, color=AZUL2, width=2)

    save(img, "rd005.png")

# ════════════════════════════════════════════════════════════════════════════
# rd006 — Runbook: estrutura e severidades
# ════════════════════════════════════════════════════════════════════════════
def rd006():
    img, d = new_img()
    title(d, "Runbooks — O Manual de Emergência")

    # Componentes
    componentes = [
        ("Trigger",     "O que ativa o runbook",         AZUL_CL),
        ("Severidade",  "P1-P4 (impacto no negócio)",     LARANJA),
        ("Diagnóstico", "Comandos para entender o problema", AZUL2),
        ("Ação",        "Passos exatos de remediação",    VERDE),
        ("Verificação", "Como confirmar resolução",       AZUL2),
        ("Escalação",   "Quem chamar se não resolver",    VERMELHO),
    ]
    for i, (comp, desc, cor) in enumerate(componentes):
        col = i % 3
        row = i // 3
        bx = 60 + col * 400
        by = 155 + row * 170
        rect(d, bx, by, bx+360, by+140, fill=cor, radius=12)
        label(d, comp, bx+180, by+40, size=24, color=BRANCO, bold=True, anchor="mm")
        # wrap texto
        words = desc.split()
        lines, cur = [], ""
        for w in words:
            test = (cur + " " + w).strip()
            if font(17).getlength(test) < 320:
                cur = test
            else:
                lines.append(cur); cur = w
        lines.append(cur)
        for j, l in enumerate(lines):
            label(d, l, bx+180, by+78+j*26, size=17, color=BRANCO, anchor="mm")

    # Tabela severidades
    rect(d, 60, 530, W-60, 690, fill=CINZA_BG, radius=10, outline="#CCCCCC", width=1)
    label(d, "Severidades:", 90, 553, size=21, color=AZUL2, bold=True, anchor="lm")
    sevs = [("P1", "Sistema fora do ar", "< 5 min", VERMELHO),
            ("P2", "Funcionalidade crítica", "< 30 min", LARANJA),
            ("P3", "Funcionalidade sec.", "< 4 h", AZUL_CL),
            ("P4", "Bug menor", "Próx. dia útil", CINZA)]
    for i, (p, desc, resp, cor) in enumerate(sevs):
        bx = 90 + i * 290
        rect(d, bx, 578, bx+30, bx+50 - bx + 578 + 20, fill=cor, radius=5)  # badge
        rect(d, bx, 580, bx+32, 616, fill=cor, radius=5)
        label(d, p, bx+16, 598, size=18, color=BRANCO, bold=True, anchor="mm")
        label(d, desc, bx+44, 591, size=17, color=AZUL2, anchor="lm")
        label(d, resp, bx+44, 613, size=15, color=CINZA, anchor="lm")

    save(img, "rd006.png")

# ════════════════════════════════════════════════════════════════════════════
# rd007 — AIOps: evolução dos níveis
# ════════════════════════════════════════════════════════════════════════════
def rd007():
    img, d = new_img()
    title(d, "AIOps — Evolução do Monitoramento")

    niveis = [
        ("Nível 1\nTradicional",  "(reativo)",    "#6C8EBF", "Thresholds fixos\nHumano analisa\nalerta manual"),
        ("Nível 2\nAIOps",        "(preditivo)",   AZUL_CL,  "Anomaly Detection\nCorrelação automática\nPrevisão de falhas"),
        ("Nível 3\nAuto-Remediação", "(autônomo)", VERDE,    "IA detecta + decide\nAção automática\nHumano só revisa"),
    ]

    XS = [60, 460, 860]
    XE = [420, 820, 1220]
    Y1 = 160

    for i, (nivel, subtitulo, cor, texto) in enumerate(niveis):
        # caixa
        rect(d, XS[i], Y1, XE[i], Y1+350, fill=cor, radius=14)
        for j, l in enumerate(nivel.split("\n")):
            label(d, l, (XS[i]+XE[i])//2, Y1+35+j*38, size=26, color=BRANCO, bold=True, anchor="mm")
        label(d, subtitulo, (XS[i]+XE[i])//2, Y1+112, size=20, color=BRANCO, anchor="mm")

        for j, linha in enumerate(texto.split("\n")):
            label(d, "• " + linha, (XS[i]+XE[i])//2, Y1+165+j*52, size=20, color=BRANCO, anchor="mm")

        if i < 2:
            arrow_h(d, XE[i]+4, XS[i+1]-4, Y1+175, color=AZUL, width=4)

    # onde a TechNova está
    rect(d, 60, 548, 820, 605, fill="#E8F4FD", radius=8, outline=AZUL_CL, width=2)
    label(d, "🏢  TechNova hoje: Nível 1-2  |  Meta desta aula: Nível 1 implementado, conceitos do Nível 2",
          440, 576, size=19, color=AZUL2, anchor="mm")

    # aviso nível 3
    rect(d, 860, 548, W-60, 605, fill="#FFF3CD", radius=8, outline=LARANJA, width=2)
    label(d, "⚠️  Nível 3: AIOps complementa,",  1040, 567, size=18, color=AZUL2, anchor="mm")
    label(d, "nunca substitui o engenheiro",         1040, 592, size=18, color=AZUL2, anchor="mm")

    save(img, "rd007.png")

# ════════════════════════════════════════════════════════════════════════════
# rd008 — CloudWatch Anomaly Detection (gráfico de banda)
# ════════════════════════════════════════════════════════════════════════════
def rd008():
    img, d = new_img()
    title(d, "CloudWatch Anomaly Detection — Banda Dinâmica")

    # área do gráfico
    GX1, GX2, GY1, GY2 = 80, 900, 130, 530
    rect(d, GX1, GY1, GX2, GY2, fill="#FAFCFF", radius=8, outline="#CCCCCC", width=1)

    # eixos
    d.line([(GX1+40, GY2-20), (GX2-20, GY2-20)], fill=AZUL2, width=2)  # X
    d.line([(GX1+40, GY1+20), (GX1+40, GY2-20)], fill=AZUL2, width=2)  # Y
    label(d, "tempo", GX2-30, GY2-5, size=16, color=CINZA, anchor="mm")
    label(d, "ms",    GX1+42, GY1+30, size=16, color=CINZA, anchor="lm")

    # marcas Y
    for val, y in [(400, GY1+60), (300, GY1+170), (200, GY1+280), (100, GY1+390)]:
        label(d, str(val), GX1+35, y, size=15, color=CINZA, anchor="rm")
        d.line([(GX1+40, y), (GX1+45, y)], fill=CINZA, width=1)

    # banda esperada (polígono verde claro)
    pts_band = [(GX1+60, GY1+230), (GX1+140, GY1+220), (GX1+240, GY1+240),
                (GX1+340, GY1+210), (GX1+440, GY1+225), (GX1+540, GY1+215),
                (GX1+640, GY1+230), (GX1+720, GY1+220), (GX1+800, GY1+230),
                (GX1+800, GY1+310), (GX1+720, GY1+300), (GX1+640, GY1+315),
                (GX1+540, GY1+305), (GX1+440, GY1+320), (GX1+340, GY1+305),
                (GX1+240, GY1+320), (GX1+140, GY1+310), (GX1+60,  GY1+315)]
    d.polygon(pts_band, fill="#C8E6C9")

    # linha da banda inferior/superior
    pts_up  = [(GX1+60, GY1+230), (GX1+140, GY1+220), (GX1+240, GY1+240),
               (GX1+340, GY1+210), (GX1+440, GY1+225), (GX1+540, GY1+215),
               (GX1+640, GY1+230), (GX1+720, GY1+220), (GX1+800, GY1+230)]
    pts_dn  = [(GX1+60, GY1+315), (GX1+140, GY1+310), (GX1+240, GY1+320),
               (GX1+340, GY1+305), (GX1+440, GY1+320), (GX1+540, GY1+305),
               (GX1+640, GY1+315), (GX1+720, GY1+300), (GX1+800, GY1+310)]
    d.line(pts_up, fill=VERDE, width=2)
    d.line(pts_dn, fill=VERDE, width=2)

    # linha de métrica (normal)
    pts_met = [(GX1+60, GY1+280), (GX1+140, GY1+265), (GX1+240, GY1+275),
               (GX1+340, GY1+258), (GX1+440, GY1+270), (GX1+540, GY1+260),
               (GX1+620, GY1+268)]
    d.line(pts_met, fill=AZUL_CL, width=3)

    # ponto de anomalia
    ANX, ANY = GX1+700, GY1+150
    pts_anom = [(GX1+620, GY1+268), (GX1+660, GY1+210), (ANX, ANY)]
    d.line(pts_anom, fill=VERMELHO, width=3)
    d.ellipse([ANX-10, ANY-10, ANX+10, ANY+10], fill=VERMELHO)
    rect(d, ANX-130, ANY-50, ANX+10, ANY-5, fill=VERMELHO, radius=6)
    label(d, "⚠ Anomalia!", ANX-60, ANY-27, size=18, color=BRANCO, bold=True, anchor="mm")

    # legenda
    for cy, cor, txt in [(GY2-45, VERDE, "Banda esperada (ML aprende por hora/dia da semana)"),
                          (GY2-20, AZUL_CL, "Métrica real"),
                          (GY2+5,  VERMELHO, "Anomalia detectada")]:
        d.rectangle([GX1+60, cy-7, GX1+80, cy+7], fill=cor)
        label(d, txt, GX1+90, cy, size=16, color=CINZA, anchor="lm")

    # painel direito — comparação
    rect(d, 920, 130, W-30, 530, fill=CINZA_BG, radius=10, outline="#CCCCCC", width=1)
    label(d, "Threshold Fixo vs Dinâmico", 1105, 160, size=22, color=AZUL2, bold=True, anchor="mm")
    comparacoes = [
        ("Fixo",    "CPU > 80%\n→ alerta"),
        ("Dinâmico","fora da banda\n→ alerta"),
    ]
    for i, (tipo, desc) in enumerate(comparacoes):
        by = 210 + i * 150
        cor = VERMELHO if i == 0 else VERDE
        rect(d, 940, by, 1250, by+120, fill=cor, radius=10)
        label(d, tipo, 1095, by+30, size=22, color=BRANCO, bold=True, anchor="mm")
        for j, l in enumerate(desc.split("\n")):
            label(d, l, 1095, by+65+j*28, size=18, color=BRANCO, anchor="mm")
    label(d, "Dinâmico reduz falsos\npositivos e detecta\ndegradação gradual",
          1095, 530, size=18, color=AZUL2, anchor="mm")

    save(img, "rd008.png")

# ════════════════════════════════════════════════════════════════════════════
# rd009 — Arquitetura AIOps Lambda + Bedrock
# ════════════════════════════════════════════════════════════════════════════
def rd009():
    img, d = new_img()
    title(d, "Arquitetura AIOps — Lambda + Bedrock")

    componentes = [
        (120,  350, "CloudWatch\n(anomalia)", AZUL_CL),
        (340,  350, "EventBridge\n(trigger)",  LARANJA),
        (560,  350, "Lambda\n(LabRole)",       AZUL2),
        (780,  350, "Bedrock\nClaude Haiku",   VERDE),
        (1000, 350, "SNS / Slack\n/ Rollback", VERMELHO),
    ]

    for i, (x, y, lbl, cor) in enumerate(componentes):
        rect(d, x-85, y-55, x+85, y+55, fill=cor, radius=12)
        for j, l in enumerate(lbl.split("\n")):
            label(d, l, x, y-15+j*32, size=19, color=BRANCO, bold=True, anchor="mm")
        if i < len(componentes)-1:
            nx = componentes[i+1][0]
            arrow_h(d, x+86, nx-86, y, color=AZUL, width=3)

    # numeração dos passos
    passos = [
        (230, 300, "1. anomalia\ndispara evento"),
        (450, 300, "2. Lambda coleta\nmétricas + logs"),
        (670, 300, "3. envia contexto\nao LLM"),
        (890, 300, "4. análise:\ncausa raiz, severidade"),
        (1000,460, "5. notifica\ne/ou reverte"),
    ]
    for px, py, txt in passos:
        for j, l in enumerate(txt.split("\n")):
            label(d, l, px, py+j*22, size=15, color=CINZA, anchor="mm")

    # caixa da resposta Bedrock
    rect(d, 60, 480, W-60, 630, fill="#F0F8FF", radius=10, outline=VERDE, width=2)
    label(d, "Resposta estruturada do Bedrock:", 100, 505, size=20, color=AZUL2, bold=True, anchor="lm")
    campos = ["severidade", "causa_raiz_provavel", "confianca", "acao_recomendada", "rollback_necessario"]
    for i, c in enumerate(campos):
        bx = 90 + i * 230
        rect(d, bx, 530, bx+210, 575, fill=AZUL2, radius=6)
        label(d, c, bx+105, 552, size=15, color=LARANJA, bold=True, anchor="mm")

    label(d, "☁  Learner Lab: Lambda usa LabRole pré-existente — o Lab não permite criar roles IAM",
          W//2, 610, size=17, color=CINZA, anchor="mm")

    save(img, "rd009.png")

# ════════════════════════════════════════════════════════════════════════════
# rd010 — Limites do AIOps (o que funciona vs o que não funciona)
# ════════════════════════════════════════════════════════════════════════════
def rd010():
    img, d = new_img()
    title(d, "Limites do AIOps — O Que Funciona Hoje")

    # Coluna FUNCIONA
    rect(d, 40, 130, 600, 560, fill="#F0FFF4", radius=14, outline=VERDE, width=2)
    label(d, "✅  Funciona bem hoje", 320, 165, size=26, color=VERDE, bold=True, anchor="mm")
    funciona = [
        "Anomaly detection em métricas",
        "Redução de ruído nos alertas",
        "Análise de logs com LLM",
        "Auto-remediação simples\n(restart, scale-out)",
    ]
    for i, t in enumerate(funciona):
        for j, l in enumerate(t.split("\n")):
            label(d, l if j > 0 else "• " + l,
                  80 if j==0 else 94, 215+i*78+j*26, size=20, color=AZUL2, anchor="lm")

    # Coluna NÃO FUNCIONA
    rect(d, 640, 130, W-40, 560, fill="#FFF0F0", radius=14, outline=VERMELHO, width=2)
    label(d, "❌  Ainda não confiável", 965, 165, size=26, color=VERMELHO, bold=True, anchor="mm")
    nao_funciona = [
        "Substituir o engenheiro de plantão",
        "Rollback autônomo sem supervisão",
        "Correlação perfeita em sistemas\ndistribuídos complexos",
        "Previsões com 100% de acerto",
    ]
    for i, t in enumerate(nao_funciona):
        for j, l in enumerate(t.split("\n")):
            label(d, l if j > 0 else "• " + l,
                  680 if j==0 else 694, 215+i*78+j*26, size=20, color=AZUL2, anchor="lm")

    # Recomendação
    rect(d, 40, 580, W-40, 660, fill="#FFF8E8", radius=10, outline=LARANJA, width=2)
    label(d, "💡  Use AIOps como complemento — mantenha thresholds fixos como safety net.",
          W//2, 605, size=19, color=AZUL2, anchor="mm")
    label(d, "Comece pelo Nível 1 (alerta + sugestão) antes de implementar auto-remediação.",
          W//2, 635, size=19, color=AZUL2, anchor="mm")

    save(img, "rd010.png")

# ════════════════════════════════════════════════════════════════════════════
# ta001 — Revisão TA: MTTR e estratégias de rollback
# ════════════════════════════════════════════════════════════════════════════
def ta001():
    img, d = new_img()
    title(d, "Revisão do TA — Rollback Strategies")

    rect(d, 40, 120, W-40, 440, fill=CINZA_BG, radius=12, outline="#CCCCCC", width=1)

    pontos = [
        ("MTTR",           "TTD + TTR — meta: automação reduz de 35 min para ~2 min"),
        ("Recreate",       "Para container → sobe anterior — tem downtime"),
        ("Blue-Green",     "Redireciona ALB → ambiente anterior — zero downtime"),
        ("Canary",         "Remove canary → 100% stable — zero downtime"),
        ("Expand-Contract","Migração em 3 fases — nunca quebre o rollback do schema"),
        ("Feature Flags",  "Ops flag = kill switch — desliga sem redeploy"),
    ]
    for i, (conceito, desc) in enumerate(pontos):
        Y = 150 + i * 46
        rect(d, 60, Y-18, 230, Y+18, fill=AZUL2, radius=6)
        label(d, conceito, 145, Y, size=18, color=BRANCO, bold=True, anchor="mm")
        label(d, desc, 250, Y, size=19, color=AZUL2, anchor="lm")

    # questão de aquecimento
    rect(d, 40, 460, W-40, 590, fill="#E8F4FD", radius=10, outline=AZUL_CL, width=2)
    label(d, "Questão de aquecimento:", 80, 488, size=21, color=AZUL2, bold=True, anchor="lm")
    label(d, "No padrão Expand-Contract, quando é seguro executar a fase CONTRACT",
          80, 520, size=19, color=AZUL2, anchor="lm")
    label(d, "(remover a coluna antiga)?",
          80, 548, size=19, color=AZUL2, anchor="lm")

    save(img, "ta001.png")

# ════════════════════════════════════════════════════════════════════════════
# ta002 — Revisão TA: AIOps e Bedrock
# ════════════════════════════════════════════════════════════════════════════
def ta002():
    img, d = new_img()
    title(d, "Revisão do TA — AIOps e Bedrock")

    rect(d, 40, 120, W-40, 440, fill=CINZA_BG, radius=12, outline="#CCCCCC", width=1)

    pontos = [
        ("Anomaly Detection", "ML aprende baseline — alerta fora da banda, não threshold fixo"),
        ("EventBridge",       "Anomalia → dispara evento → invoca Lambda"),
        ("Lambda + Bedrock",  "Lambda coleta contexto e chama Claude Haiku para análise"),
        ("LabRole",           "Learner Lab: Lambda usa LabRole pré-existente, não cria roles"),
        ("Resposta Bedrock",  "causa raiz, severidade, confiança, ação, rollback_necessario"),
        ("Limites",           "AIOps complementa — não substitui o engenheiro de plantão"),
    ]
    for i, (conceito, desc) in enumerate(pontos):
        Y = 150 + i * 46
        rect(d, 60, Y-18, 260, Y+18, fill=VERDE, radius=6)
        label(d, conceito, 160, Y, size=17, color=BRANCO, bold=True, anchor="mm")
        label(d, desc, 280, Y, size=18, color=AZUL2, anchor="lm")

    rect(d, 40, 460, W-40, 590, fill="#E8F4FD", radius=10, outline=AZUL_CL, width=2)
    label(d, "Questão de aquecimento:", 80, 488, size=21, color=AZUL2, bold=True, anchor="lm")
    label(d, "Por que a Lambda coleta métricas e logs ANTES de enviar para o Bedrock,",
          80, 520, size=19, color=AZUL2, anchor="lm")
    label(d, "em vez de deixar o Bedrock buscar diretamente no CloudWatch?",
          80, 548, size=19, color=AZUL2, anchor="lm")

    save(img, "ta002.png")


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    print("Gerando imagens da Aula 12...")
    rd001(); rd002(); rd003(); rd004(); rd005()
    rd006(); rd007(); rd008(); rd009(); rd010()
    ta001(); ta002()
    print("Done — 12 imagens geradas em", OUT)
