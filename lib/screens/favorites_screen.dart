import 'package:flutter/material.dart';

import '../models/weather_models.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onSelected,
    required this.onRemoved,
  });

  final List<WeatherLocation> favorites;
  final ValueChanged<WeatherLocation> onSelected;
  final ValueChanged<WeatherLocation> onRemoved;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Favorite places',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your saved forecasts, ready whenever you are.',
                  style: TextStyle(color: Colors.blueGrey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? const _EmptyFavorites()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: favorites.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final location = favorites[index];
                      return Dismissible(
                        key: ValueKey(location.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => onRemoved(location),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFFE4EC),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFFF4D7D),
                              ),
                            ),
                            title: Text(
                              location.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              location.subtitle.isEmpty
                                  ? 'Saved location'
                                  : location.subtitle,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => onSelected(location),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: Color(0xFFFF4D7D),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Open any city forecast and tap the heart to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
