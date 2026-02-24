class AppConstants {
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const int maxTokens = 2048;

  static const List<Map<String, dynamic>> presetEvents = [
    {
      'title': 'French Revolution',
      'subtitle': '1789–1799',
      'emoji': '⚔️',
      'category': 'Revolution',
      'description': 'The period of political and social transformation in France that overthrew the monarchy.',
    },
    {
      'title': 'Battle of Plassey',
      'subtitle': '1757',
      'emoji': '🏹',
      'category': 'Conquest',
      'description': 'A decisive victory of the British East India Company over Nawab of Bengal, beginning British rule in India.',
    },
    {
      'title': 'Moon Landing',
      'subtitle': '1969',
      'emoji': '🌕',
      'category': 'Space',
      'description': 'NASA\'s Apollo 11 mission saw humans walk on the Moon for the first time.',
    },
    {
      'title': 'Crusades',
      'subtitle': '1096–1291',
      'emoji': '✝️',
      'category': 'Religion',
      'description': 'A series of religious wars sanctioned by the Latin Church to recover the Holy Land.',
    },
    {
      'title': 'Industrial Revolution',
      'subtitle': '1760–1840',
      'emoji': '⚙️',
      'category': 'Economy',
      'description': 'Transition to new manufacturing processes in Europe and the United States.',
    },
    {
      'title': 'Partition of India',
      'subtitle': '1947',
      'emoji': '🇮🇳',
      'category': 'Politics',
      'description': 'The division of British India into the independent nations of India and Pakistan.',
    },
    {
      'title': 'World War II',
      'subtitle': '1939–1945',
      'emoji': '🌍',
      'category': 'War',
      'description': 'A global war that involved most of the world\'s nations, ending with Allied victory.',
    },
    {
      'title': 'Fall of the Berlin Wall',
      'subtitle': '1989',
      'emoji': '🧱',
      'category': 'Politics',
      'description': 'The fall of the Berlin Wall marked the end of the Cold War and German reunification.',
    },
    {
      'title': 'Opium Wars',
      'subtitle': '1839–1860',
      'emoji': '🚢',
      'category': 'Trade',
      'description': 'Conflicts between the Qing dynasty and Western powers over trade and sovereignty.',
    },
    {
      'title': 'Rwandan Genocide',
      'subtitle': '1994',
      'emoji': '🕊️',
      'category': 'Tragedy',
      'description': 'A mass slaughter of Tutsi, Twa, and moderate Hutu in Rwanda.',
    },
    {
      'title': 'The Reformation',
      'subtitle': '1517–1648',
      'emoji': '📜',
      'category': 'Religion',
      'description': 'Martin Luther\'s challenge to the Catholic Church that split Western Christianity.',
    },
    {
      'title': 'Hiroshima & Nagasaki',
      'subtitle': '1945',
      'emoji': '☢️',
      'category': 'War',
      'description': 'The atomic bombings by the United States that hastened the end of World War II.',
    },
  ];
}
