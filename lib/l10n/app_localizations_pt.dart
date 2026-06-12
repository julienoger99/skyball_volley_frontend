// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appSubtitle => 'Vôlei';

  @override
  String get fieldRequired => 'Campo obrigatório';

  @override
  String get loginTitle => 'SKYBALL';

  @override
  String get loginUsername => 'Nome de usuário';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginButton => 'ENTRAR';

  @override
  String get loginNoAccount => 'Ainda não tem conta? ';

  @override
  String get loginCreateAccount => 'Criar uma conta';

  @override
  String get loginErrorInvalidCredentials => 'Credenciais inválidas.';

  @override
  String get loginErrorNotVerified =>
      'Conta não verificada. Verifique seus e-mails.';

  @override
  String get loginErrorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get registerTitle => 'CRIAR UMA CONTA';

  @override
  String get registerSubtitle => 'Junte-se à comunidade Skyball';

  @override
  String get registerUsername => 'Nome de usuário';

  @override
  String get registerEmail => 'Endereço de e-mail';

  @override
  String get registerEmailInvalid => 'E-mail inválido';

  @override
  String get registerPassword => 'Senha';

  @override
  String get registerPasswordTooShort => 'Mínimo 6 caracteres';

  @override
  String get registerConfirmPassword => 'Confirmar senha';

  @override
  String get registerPasswordMismatch => 'As senhas não coincidem';

  @override
  String get registerButton => 'CRIAR MINHA CONTA';

  @override
  String get registerAlreadyAccount => 'Já tem conta? ';

  @override
  String get registerLoginLink => 'Entrar';

  @override
  String get registerSuccessTitle => 'Cadastro realizado';

  @override
  String get registerError409 => 'Nome de usuário ou e-mail já utilizado.';

  @override
  String get registerError400 => 'Dados inválidos. Verifique suas informações.';

  @override
  String get registerErrorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get tabHome => 'Início';

  @override
  String get tabMatches => 'Partidas';

  @override
  String get tabTeams => 'Times';

  @override
  String get tabProfile => 'Perfil';

  @override
  String homeGreeting(String username) {
    return 'Olá, $username!';
  }

  @override
  String get homeNextMatch => 'Próxima partida';

  @override
  String get homeRecentResults => 'Resultados recentes';

  @override
  String get homeNoTeam => 'Junte-se a um time para ver suas partidas.';

  @override
  String get homeNoUpcomingMatch => 'Nenhuma partida agendada.';

  @override
  String get homeNoRecentResults => 'Nenhum resultado recente.';

  @override
  String get homeHome => 'Casa';

  @override
  String get homeAway => 'Fora';

  @override
  String get homeVs => 'vs';

  @override
  String get homeWin => 'Vitória';

  @override
  String get homeLoss => 'Derrota';

  @override
  String get homeDraw => 'Empate';

  @override
  String get homeRetry => 'Tentar novamente';

  @override
  String get homeLoadError => 'Não foi possível carregar os dados.';

  @override
  String get teamCategory => 'Categoria';

  @override
  String get teamGender => 'Gênero';

  @override
  String get teamClub => 'Clube';

  @override
  String get teamMembers => 'Membros';

  @override
  String get teamNoMembers => 'Nenhum membro.';

  @override
  String get teamViewMatches => 'Ver partidas';

  @override
  String get teamLoadError => 'Não foi possível carregar o time.';

  @override
  String get tabClub => 'Clube';

  @override
  String get clubMyClub => 'Meu clube';

  @override
  String clubFounded(String year) {
    return 'Fundado em $year';
  }

  @override
  String get clubWebsite => 'Site';

  @override
  String get clubNoClub => 'Você não está em nenhum clube';

  @override
  String get clubNoClubSub =>
      'Entre em um clube para acessar seus times e competições.';

  @override
  String get clubFindClub => 'Encontrar um clube';

  @override
  String get clubLeave => 'Sair do clube';

  @override
  String get clubLeaveConfirm => 'Sair do clube?';

  @override
  String get clubLeaveConfirmMessage =>
      'Isso também removerá você de todos os times deste clube.';

  @override
  String get clubTeams => 'Times do clube';

  @override
  String clubAutoJoinTitle(String clubName) {
    return 'Entrar em $clubName?';
  }

  @override
  String clubAutoJoinMessage(String clubName) {
    return 'Este time pertence ao $clubName. Você vai entrar automaticamente neste clube.';
  }

  @override
  String get teamsMyTeams => 'Meus times';

  @override
  String get teamsExplore => 'Explorar';

  @override
  String get teamsJoin => 'Entrar';

  @override
  String get teamsLeave => 'Sair';

  @override
  String get teamsNoMyTeams => 'Você ainda não faz parte de nenhum time.';

  @override
  String get teamsLoadError => 'Não foi possível carregar os times.';

  @override
  String get teamsDifferentClub => 'Você já pertence a outro clube.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get member => 'Membro';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileLogout => 'Sair';

  @override
  String get profileLogoutConfirm => 'Sair?';

  @override
  String get profileLogoutMessage =>
      'Você será redirecionado para a página de login.';

  @override
  String profileTeams(int count) {
    return '$count time(s)';
  }

  @override
  String get matchesUpcoming => 'Próximos';

  @override
  String get matchesResults => 'Resultados';

  @override
  String get matchesNoUpcoming => 'Nenhum próximo jogo.';

  @override
  String get matchesNoResults => 'Nenhum resultado.';

  @override
  String get matchesLoadError => 'Não foi possível carregar os jogos.';

  @override
  String get matchesMyMatches => 'Meus jogos';

  @override
  String get matchesChampionships => 'Campeonatos';

  @override
  String get champLoadError => 'Não foi possível carregar o campeonato.';

  @override
  String get champNoChampionships => 'Nenhum campeonato ainda.';

  @override
  String get champNew => 'Novo campeonato';

  @override
  String get champEdit => 'Editar campeonato';

  @override
  String get champName => 'Nome';

  @override
  String get champSeason => 'Temporada';

  @override
  String get champCategory => 'Categoria';

  @override
  String get champSave => 'Guardar';

  @override
  String get champMatches => 'Jogos';

  @override
  String get champNoMatches => 'Nenhum jogo neste campeonato.';

  @override
  String get champDelete => 'Eliminar';

  @override
  String get champDeleteConfirm => 'Eliminar campeonato?';

  @override
  String champDeleteConfirmMessage(String name) {
    return '\"$name\" será eliminado definitivamente.';
  }

  @override
  String get matchLoadError => 'Não foi possível carregar o jogo.';

  @override
  String get matchDelete => 'Eliminar';

  @override
  String get matchDeleteConfirm => 'Eliminar jogo?';

  @override
  String get matchDeleteConfirmMessage =>
      'Este jogo e os seus dados serão eliminados definitivamente.';

  @override
  String get matchSets => 'Sets';

  @override
  String get matchNoSets => 'Nenhum set registado.';

  @override
  String get matchAddSet => 'Adicionar set';

  @override
  String get matchSet => 'Set';

  @override
  String get matchPlayers => 'Jogadores';

  @override
  String get matchNoPlayers => 'Nenhum jogador.';

  @override
  String get matchCaptain => 'Capitão';

  @override
  String get matchSetCaptain => 'Definir capitão';

  @override
  String get matchTeamPoints => 'Minha equipa';

  @override
  String get matchOpponentPoints => 'Adversário';

  @override
  String get attendancePresent => 'Presente';

  @override
  String get attendanceAbsent => 'Ausente';

  @override
  String get attendanceUnknown => 'Indefinido';

  @override
  String get matchStatusScheduled => 'Agendado';

  @override
  String get matchStatusPlayed => 'Jogado';

  @override
  String get matchStatusCancelled => 'Cancelado';

  @override
  String get matchStatusPostponed => 'Adiado';

  @override
  String get matchStatusForfeit => 'Falta';

  @override
  String get matchCreate => 'Novo jogo';

  @override
  String get matchEditTitle => 'Editar jogo';

  @override
  String get matchTeam => 'Equipa';

  @override
  String get matchOpponent => 'Adversário';

  @override
  String get matchDate => 'Data';

  @override
  String get matchPickDate => 'Escolher data';

  @override
  String get matchLocation => 'Local';

  @override
  String get matchHome => 'Em casa';

  @override
  String get matchChampionship => 'Campeonato';

  @override
  String get matchNoChampionship => 'Nenhum';

  @override
  String get matchStatus => 'Estado';

  @override
  String get matchForfeitedBy => 'Falta de';

  @override
  String get matchCoachMessage => 'Mensagem do treinador';

  @override
  String get matchDateRequired => 'Data obrigatória';

  @override
  String get matchTeamRequired => 'Seleciona uma equipa';

  @override
  String get clubName => 'Nome';

  @override
  String get clubCreate => 'Criar um clube';

  @override
  String get clubEdit => 'Editar clube';

  @override
  String get clubDelete => 'Eliminar';

  @override
  String get clubDeleteConfirm => 'Eliminar clube?';

  @override
  String clubDeleteConfirmMessage(String name) {
    return '\"$name\" e os seus dados serão eliminados definitivamente.';
  }

  @override
  String get clubCity => 'Cidade';

  @override
  String get clubDescription => 'Descrição';

  @override
  String get clubWebsiteUrl => 'Site web';

  @override
  String get clubLogoUrl => 'URL do logótipo';

  @override
  String get clubMembers => 'Membros';

  @override
  String get clubNoMembers => 'Nenhum membro.';

  @override
  String get teamCreate => 'Criar uma equipa';

  @override
  String get teamEdit => 'Editar equipa';

  @override
  String get teamDelete => 'Eliminar';

  @override
  String get teamDeleteConfirm => 'Eliminar equipa?';

  @override
  String teamDeleteConfirmMessage(String name) {
    return '\"$name\" e os seus dados serão eliminados definitivamente.';
  }

  @override
  String get teamName => 'Nome';

  @override
  String get teamLogoUrl => 'URL do logótipo';

  @override
  String get teamGenderLabel => 'Género';

  @override
  String get memberRemove => 'Remover do grupo';

  @override
  String get roleMember => 'Membro';

  @override
  String get roleManager => 'Gestor';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get errorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get loginForgotPassword => 'Esqueceu a palavra-passe?';

  @override
  String get forgotTitle => 'Esqueci a palavra-passe';

  @override
  String get forgotSubtitle =>
      'Introduz o teu email para receber um link de redefinição.';

  @override
  String get forgotSendButton => 'Enviar link';

  @override
  String get forgotSent =>
      'Se existir uma conta para este email, foi enviado um link de redefinição.';

  @override
  String get forgotHaveCode => 'Já tenho um código';

  @override
  String get backToLogin => 'Voltar ao início de sessão';

  @override
  String get resetTitle => 'Redefinir palavra-passe';

  @override
  String get resetSubtitle =>
      'Introduz o código recebido por email e a tua nova palavra-passe.';

  @override
  String get resetToken => 'Código de redefinição';

  @override
  String get resetNewPassword => 'Nova palavra-passe';

  @override
  String get resetConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get resetButton => 'Redefinir';

  @override
  String get resetSuccess =>
      'Palavra-passe redefinida. Já podes iniciar sessão.';

  @override
  String get verifyTitle => 'Verificar email';

  @override
  String get verifySubtitle =>
      'Introduz o código de verificação recebido por email.';

  @override
  String get verifyToken => 'Código de verificação';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get verifySuccess => 'Email verificado. Já podes iniciar sessão.';

  @override
  String get verifyHaveCode => 'Tenho um código de verificação';

  @override
  String get verifyResendButton => 'Reenviar email de verificação';

  @override
  String get verifyResendPrompt =>
      'Introduz o teu email para receber um novo link.';

  @override
  String get verifyResendSent =>
      'Email de verificação enviado. Verifica a tua caixa de entrada.';

  @override
  String get profileDangerZone => 'Zona sensível';

  @override
  String get profileDeleteAccount => 'Eliminar a minha conta';

  @override
  String get profileDeleteConfirm => 'Eliminar conta?';

  @override
  String get profileDeleteMessage =>
      'Esta ação é irreversível. Todos os teus dados serão eliminados definitivamente.';

  @override
  String get profileDeleteButton => 'Eliminar definitivamente';

  @override
  String get memberAdd => 'Adicionar membro';

  @override
  String get memberPickTitle => 'Adicionar membro';

  @override
  String get memberSearchHint => 'Pesquisar por nome ou email';

  @override
  String get memberNoResults => 'Nenhum utilizador encontrado.';

  @override
  String get memberAlreadyIn => 'Já é membro';

  @override
  String get memberAdded => 'Membro adicionado.';
}
