require "set"

class GameSimulator
  TACTIC_MODIFIERS = {
    "Agressiva" => { attack: 15, defense: -10, vigor_decrease: 15 },
    "Balanceada" => { attack: 0, defense: 0, vigor_decrease: 10 },
    "Defensiva" => { attack: -10, defense: 15, vigor_decrease: 5 }
  }

  PLAYER_NAMES = {
    "goleiros" => [
      "Thiagão", "Fernando", "Wigg", "Rodrigo", "Ronaldo", "Daniel"
    ],
    "zagueiros" => [
      "Coutinho", "Beto", "Paulo", "Marcola", "Pablo Escobar", "Yago Pikachu",
      "Arnaldo Antunes", "Luiza", "Andrey", "Geraldo Alckmin", "Junior Baiano"
    ],
    "meias" => [
      "Perdigão", "Larririo", "Briano", "Daniel Finance", "Rosi", "Selton Mello", "Zampio"
    ],
    "atacantes" => [
      "Renan", "João Pedro", "Riul", "Leandro", "Rheceba", "Nelson", "Matheus Poli"
    ]
  }.freeze

  EVENTS = {
    midfield: [
      "[Time] troca passes no círculo central.",
      "Jogo muito estudado, a bola fica presa no meio-campo.",
      "Dividida dura no meio-campo! A posse continua com [Time].",
      "Passe errado de [Jogador]! O time adversário recupera a bola.",
      "[Time] valoriza a posse de bola, esperando uma brecha.",
      "[Adversário] rouba a bola e tenta armar o contra-ataque!"
    ],
    offensive_build_up: [
      "[Time] avança pelo lado direito do campo!",
      "Bela jogada pela esquerda, o lateral apoia o ataque.",
      "[Jogador A] faz uma bela tabela com [Jogador B]!",
      "[Jogador] faz um passe em profundidade buscando o atacante!",
      "Que drible! [Jogador] deixou o marcador na saudade!",
      "[Jogador] parte pra cima da marcação em velocidade!",
      "Cruzamento perigoso na área!",
      "A bola é alçada na área para o centroavante!"
    ],
    defensive_action: [
      "O zagueiro chega junto e corta a jogada.",
      "Carrinho preciso de [Defensor]! A bola sai pela lateral.",
      "Interceptação crucial de [Jogador] no meio-campo!",
      "A defesa do [Time] se posta bem e fecha os espaços.",
      "O zagueiro sobe mais que o atacante e afasta de cabeça.",
      "Que recuperação! [Defensor] corre muito e consegue o desarme.",
      "[Jogador] tenta o drible e é desarmado sem falta.",
      "A linha de impedimento funciona e o bandeira marca a irregularidade."
    ],
    shot_attempt: [
      "[Jogador] ajeita para a perna boa e... CHUTOU!",
      "Bomba de fora da área! A bola passa perto!",
      "[Jogador] recebe dentro da área, girou e bateu!",
      "Chute colocado buscando o ângulo!",
      "A bola desvia na zaga e quase engana o [Goleiro]!",
      "Bateu de primeira! Que perigo!",
      "A bola passou raspando a trave!",
      "O chute explode no peito do zagueiro!"
    ],
    goal: [
      "GOOOOOOOOOOOOOOOOL!",
      "É DO [Time]! A torcida vai à loucura!",
      "[Jogador] abre o placar no [Estádio]!",
      "Que golaço! A bola foi no ângulo!",
      "Gol de cabeça! [Jogador] sobe no terceiro andar!",
      "É bola na rede! Está tudo igual novamente!",
      "[Jogador] aproveita o rebote e marca!"
    ],
    save: [
      "DEFENDEU O GOLEIRO!",
      "QUE MILAGRE! Uma defesa espetacular de [Goleiro]!",
      "O [Goleiro] sai do gol com segurança e fica com a bola.",
      "ESPALMA PRA ESCANTEIO! O [Goleiro] evita o gol.",
      "Defesa tranquila, sem dar rebote."
    ],
    random: [
      "A bola bate no juiz e a posse se inverte!",
      "Os jogadores discutem asperamente após a jogada.",
      "Uma nevasca começa dentro do campo",
      "Chuva de papel paralisa o jogo, mas já voltamos!",
      "Alerta de Irrigação! Os sprinklers do gramado ligam sozinhos no meio do ataque e dão um banho em todo mundo!",
      "Invasor Inusitado! Um cachorro invade o campo, dribla o zagueiro com uma série de fintas e sai com a bola nos dentes.",
      "VAR Misterioso! O árbitro vai ao VAR checar um lance e a tela acidentalmente exibe a receita de um bolo de fubá por 15 segundos.",
      "Delivery Aéreo! Um drone de delivery de comida sobrevoa a pequena área e quase derruba um lanche na cabeça do [Goleiro].",
      "Crise Existencial! [Jogador] para com a bola no pé, olha para o céu e parece questionar o sentido da vida. Ele perde a posse.",
      "Momento TikTok! Do nada, [Jogador] começa a ensaiar uma dancinha viral no círculo central. Ninguém entendeu o motivo.",
      "Pausa para o Lanche! O vendedor de pipoca se distrai, entra em campo e oferece seus produtos aos jogadores no meio da partida.",
      "Calma, Campeã! Uma capivara entra tranquilamente no gramado, come um pouco de grama perto da bandeirinha de escanteio e se retira.",
      "Problema de Calçado! [Jogador] perde a chuteira, mas continua a jogada e, sem querer, dá um passe perfeito usando apenas a meia.",
      "Trilha Sonora Trocada! O sistema de som do estádio toca \"Baby Shark\" em volume máximo por 30 segundos, confundindo todos os atletas.",
      "O Árbitro Poeta! Em vez de dar cartão, o juiz chama [Jogador] para um canto e declama um haicai sobre fair-play.",
      "Visitante Alado! Um pombo pousa no travessão e se recusa a sair, atrapalhando a visão do [Goleiro] em um momento crucial do jogo."
    ]
  }

  def self.call(game)
    new(game).call
  end

  def initialize(game)
    @game = game
    @players = @game.players.order(:created_at)
    @used_names = Set.new

    @teams = {
      @players.first.id => { name: @players.first.team_name, tactic: @players.first.tactic, players: build_team_players, manager: @players.first, score: -> { @game.score_team_a } },
      @players.second.id => { name: @players.second.team_name, tactic: @players.second.tactic, players: build_team_players, manager: @players.second, score: -> { @game.score_team_b } }
    }

    @possession = @players.sample.id
    @ball_zone = :midfield
  end

  def call
    run_simulation
  end

  private

  def run_simulation
    create_event(0, "Apita o árbitro! A bola está com o #{@teams[@possession][:name]}.")
    sleep 2

    (1..90).each do |minute|
      update_vigor(minute)
      simulate_minute(minute)
      sleep 2
    end

    create_event(90, "Fim de jogo!")
    @game.update(status: "finalizado")
  end

  def update_vigor(minute)
    return unless minute % 15 == 0

    @teams.each do |_, team|
      decrease_rate = TACTIC_MODIFIERS[team[:tactic]][:vigor_decrease]
      team[:players].each { |p| p[:vigor] -= decrease_rate }
    end
    create_event(minute, "Os jogadores sentem o cansaço da partida.")
  end

  def simulate_minute(minute)
    attacker_team = @teams[@possession]
    defender_team = @teams.values.find { |t| t != attacker_team }

    # Random cosmetic event chance
    if rand(100) < 5 # 5% chance for a random event
      create_event(minute, generate_event_text(:random, attacker_team, defender_team))
      return
    end

    case @ball_zone
    when :midfield
      attacker_player = attacker_team[:players].select { |p| p[:position] == "Meia" }.sample
      defender_player = defender_team[:players].select { |p| p[:position] == "Meia" }.sample
      action_type = :attack
      event_category = :midfield
    when :attack
      attacker_player = attacker_team[:players].select { |p| p[:position] == "Atacante" }.sample
      defender_player = defender_team[:players].select { |p| p[:position] == "Zagueiro" }.sample
      action_type = :attack
      event_category = :offensive_build_up
    when :defense
      attacker_player = attacker_team[:players].select { |p| p[:position] == "Lateral" }.sample
      defender_player = defender_team[:players].select { |p| p[:position] == "Atacante" }.sample
      action_type = :defense
      event_category = :defensive_action
    end

    create_event(minute, generate_event_text(event_category, attacker_team, defender_team, attacker_player, defender_player))
    sleep 1

    if @ball_zone == :attack && rand(100) < 40
      simulate_shot(minute, attacker_player, defender_team)
      return
    end

    attacker_score = calculate_action_score(attacker_player, attacker_team, action_type)
    defender_score = calculate_action_score(defender_player, defender_team, :defense)

    if attacker_score > defender_score
      create_event(minute, generate_event_text(:offensive_build_up, attacker_team, defender_team, attacker_player, defender_player, true))
      @ball_zone = @ball_zone == :defense ? :midfield : :attack
    else
      create_event(minute, generate_event_text(:defensive_action, attacker_team, defender_team, attacker_player, defender_player, true))
      @possession = defender_team[:manager].id
      @ball_zone = :midfield
    end
  end

  def simulate_shot(minute, shooter, defender_team)
    create_event(minute, generate_event_text(:shot_attempt, @teams[@possession], defender_team, shooter))
    sleep 1

    goalkeeper = defender_team[:players].find { |p| p[:position] == "Goleiro" }

    shooter_score = calculate_action_score(shooter, @teams[@possession], :attack)
    keeper_score = calculate_action_score(goalkeeper, defender_team, :defense)

    if shooter_score > keeper_score
      if @possession == @players.first.id
        @game.score_team_a = @game.score_team_a.to_i + 1
      else
        @game.score_team_b = @game.score_team_b.to_i + 1
      end
      @game.save
      @game.broadcast_replace_to(@game, target: ActionView::RecordIdentifier.dom_id(@game, :scoreboard), partial: "games/scoreboard", locals: { game: @game })

      # Broadcast goal audio event
      @game.broadcast_action_to(@game, action: :goal_audio)

      create_event(minute, generate_event_text(:goal, @teams[@possession], defender_team, shooter))

      @possession = defender_team[:manager].id
      @ball_zone = :midfield
    else
      create_event(minute, generate_event_text(:save, @teams[@possession], defender_team, goalkeeper))
      handle_post_shot_outcome(minute, defender_team)
    end
  end

  def handle_post_shot_outcome(minute, defending_team)
    roll = rand(100) + 1 # 1 to 100

    if roll <= 60
      create_event(minute, "Reposição de bola com o goleiro.")
      @possession = defending_team[:manager].id
      @ball_zone = :defense
    elsif roll <= 85
      create_event(minute, "Escanteio para o time que atacou!")
      # Possession stays with attacking team, ball in attack zone
      @ball_zone = :attack
    elsif roll <= 95
      create_event(minute, "Arremesso lateral!")
      # Possession stays with attacking team, ball in midfield
      @ball_zone = :midfield
    else # 96-100
      create_event(minute, "Rebote perigoso na área! Nova disputa de bola!")
      # Immediately trigger a new dispute in the same minute
      simulate_minute(minute) # Recursive call for immediate dispute
    end
  end

  def calculate_action_score(player, team, action_type)
    tactic_modifier = TACTIC_MODIFIERS[team[:tactic]][action_type]
    luck_factor = rand(-10..10)

    # Antigoleada Rule
    score_diff = team[:score].call - @teams.values.find { |t| t != team }[:score].call
    if score_diff >= 3 && action_type == :attack
      tactic_modifier -= 10
    elsif score_diff <= -3 && action_type == :defense
      tactic_modifier += 10
    end

    vigor = [ player[:vigor], 0 ].max # Ensure vigor doesn't go below 0
    score = (player[:overall] * 0.6) + (vigor * 0.4) + tactic_modifier + luck_factor
    score.round(2)
  end

  def generate_event_text(category, attacking_team, defending_team, attacker_player = nil, defender_player = nil, dispute_outcome = false)
    event_text = EVENTS[category].sample

    event_text.gsub!("[Time]", attacking_team[:name])
    event_text.gsub!("[Adversário]", defending_team[:name])

    # Para eventos aleatórios, selecionar um jogador aleatório se não há attacker_player específico
    if attacker_player
      event_text.gsub!("[Jogador]", attacker_player[:name])
    elsif category == :random && event_text.include?("[Jogador]")
      # Selecionar um jogador aleatório de qualquer posição do time atacante
      random_player = attacking_team[:players].sample
      event_text.gsub!("[Jogador]", random_player[:name])
    end

    event_text.gsub!("[Defensor]", defender_player[:name]) if defender_player
    event_text.gsub!("[Jogador A]", attacking_team[:players].sample[:name])
    event_text.gsub!("[Jogador B]", attacking_team[:players].sample[:name])
    event_text.gsub!("[Goleiro]", defending_team[:players].find { |p| p[:position] == "Goleiro" }[:name])
    event_text.gsub!("[Estádio]", "Maracanã")

    event_text
  end

  def create_event(minute, description)
    GameEvent.create(game: @game, minute: minute, description: description)
  end

  def get_unique_name(position_category)
    available_names = PLAYER_NAMES[position_category] - @used_names.to_a

    # Se não há nomes disponíveis nesta categoria, usar qualquer nome disponível
    if available_names.empty?
      all_names = PLAYER_NAMES.values.flatten
      available_names = all_names - @used_names.to_a
    end

    # Se ainda assim não há nomes, usar um nome genérico (fallback)
    if available_names.empty?
      return "Jogador #{@used_names.size + 1}"
    end

    selected_name = available_names.sample
    @used_names << selected_name
    selected_name
  end

  def build_team_players
    [
      { name: get_unique_name("goleiros"), overall: 65, vigor: 100, position: "Goleiro" },
      { name: get_unique_name("zagueiros"), overall: 62, vigor: 100, position: "Lateral" },
      { name: get_unique_name("zagueiros"), overall: 62, vigor: 100, position: "Lateral" },
      { name: get_unique_name("zagueiros"), overall: 78, vigor: 100, position: "Zagueiro" },
      { name: get_unique_name("zagueiros"), overall: 45, vigor: 100, position: "Zagueiro" },
      { name: get_unique_name("meias"), overall: 68, vigor: 100, position: "Meia" },
      { name: get_unique_name("meias"), overall: 68, vigor: 100, position: "Meia" },
      { name: get_unique_name("meias"), overall: 68, vigor: 100, position: "Meia" },
      { name: get_unique_name("meias"), overall: 68, vigor: 100, position: "Meia" },
      { name: get_unique_name("atacantes"), overall: 80, vigor: 100, position: "Atacante" },
      { name: get_unique_name("atacantes"), overall: 48, vigor: 100, position: "Atacante" }
    ]
  end
end
