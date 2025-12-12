import "package:shared_preferences/shared_preferences.dart";

// SHARED PREFERENCES SERVICE

// GERENCIADOR DE NÍVEL
// Aumenta o nível, quando chamado de outras páginas
// Pode ter nível atual, quantidade de XP atual e quantidade necessária acessadas de qualquer página!

class SharedPreferencesService {
  static int localCurrentLevel = 1;
  static int localCurrentXp = 0;

  // Indices do avatar
  static int avatarHeadIndex = 5;
  static int avatarHairIndex = 5;
  static int avatarClothIndex = 1;
  static int avatarMouthIndex = 1;
  static int avatarEyeIndex = 1;

  // Itens do avatar que podem ser desbloqueados
  static bool cloth2Locked = true;
  static bool cloth3Locked = true;
  static bool cloth4Locked = true;

  static bool mouth2Locked = true;
  static bool mouth3Locked = true;

  static bool eye2Locked = true;
  static bool eye3Locked = true;
  static bool eye4Locked = true;
  static bool eye5Locked = true;
  static bool eye6Locked = true;

  // Moedas
  static int currentCoins = 0;

  SharedPreferencesService.privateConstructor();

  // Acesso global
  // Quantidade de XP necessária sempre será o nível atual + 10
  static int get currentLevel => localCurrentLevel;
  static int get currentXp => localCurrentXp;
  static int get totalXpRequired => localCurrentLevel + 10;

  // Adiciona XP e retorna se subiu de nível
  static bool addXp(int xp) {
    if (xp <= 0) return false;

    localCurrentXp += xp;
    bool leveledUp = false;

    // Se houver XP suficiente sobe de nível
    while (localCurrentXp >= totalXpRequired) {
      localCurrentXp = 0;
      localCurrentLevel++;
      leveledUp = true;
    }

    saveData();
    return leveledUp;
  }

  // Adiciona moedas
  static void addCoins(int coins) {
    currentCoins += coins;
    saveData();
  }

  // Remove moedas
  static void spendCoins(int coins) {
    currentCoins -= coins;
    saveData();
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Nivel e XP
    await prefs.setInt("level", localCurrentLevel);
    await prefs.setInt("xp", localCurrentXp);

    // Avatar
    await prefs.setInt("avatarHead", avatarHeadIndex);
    await prefs.setInt("avatarHair", avatarHairIndex);
    await prefs.setInt("avatarCloth", avatarClothIndex);
    await prefs.setInt("avatarMouth", avatarMouthIndex);
    await prefs.setInt("avatarEye", avatarEyeIndex);

    // Moedas
    await prefs.setInt("currentCoins", currentCoins);
    // Avatar - itens com bloqueio
    await prefs.setBool("cloth2Locked", cloth2Locked);
    await prefs.setBool("cloth3Locked", cloth3Locked);
    await prefs.setBool("cloth4Locked", cloth4Locked);

    await prefs.setBool("mouth2Locked", mouth2Locked);
    await prefs.setBool("mouth3Locked", mouth3Locked);

    await prefs.setBool("eye2Locked", eye2Locked);
    await prefs.setBool("eye3Locked", eye3Locked);
    await prefs.setBool("eye4Locked", eye4Locked);
    await prefs.setBool("eye5Locked", eye5Locked);
    await prefs.setBool("eye6Locked", eye6Locked);
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Nivel e XP
    localCurrentLevel = prefs.getInt("level") ?? 1;
    localCurrentXp = prefs.getInt("xp") ?? 0;

    // Avatar
    avatarHeadIndex = prefs.getInt("avatarHead") ?? 0;
    avatarHairIndex = prefs.getInt("avatarHair") ?? 0;
    avatarClothIndex = prefs.getInt("avatarCloth") ?? 0;
    avatarMouthIndex = prefs.getInt("avatarMouth") ?? 0;
    avatarEyeIndex = prefs.getInt("avatarEye") ?? 0;

    // Moedas
    currentCoins = prefs.getInt("currentCoins") ?? 0;

    // Avatar - itens com bloqueio
    cloth2Locked = prefs.getBool("cloth2Locked") ?? true;
    cloth3Locked = prefs.getBool("cloth3Locked") ?? true;
    cloth4Locked = prefs.getBool("cloth4Locked") ?? true;

    mouth2Locked = prefs.getBool("mouth2Locked") ?? true;
    mouth3Locked = prefs.getBool("mouth3Locked") ?? true;

    eye2Locked = prefs.getBool("eye2Locked") ?? true;
    eye3Locked = prefs.getBool("eye3Locked") ?? true;
    eye4Locked = prefs.getBool("eye4Locked") ?? true;
    eye5Locked = prefs.getBool("eye5Locked") ?? true;
    eye6Locked = prefs.getBool("eye6Locked") ?? true;
  }
}
