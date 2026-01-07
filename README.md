# MiniBookPlayer

## Опис додатку

**MiniBookPlayer** — це простий iOS-додаток для відтворення аудіокниги, побудований на SwiftUI та The Composable Architecture (TCA).

Аудіокнига **зберігається локально в ресурсах додатку**:

* JSON-файл з описом книги та ключових розділів (key points)
* локальні аудіофайли для кожного розділу

Додаток дозволяє:

* завантажити книгу з локальних ресурсів
* відтворювати аудіо по розділах
* перемикатися між розділами
* змінювати швидкість відтворення
* перемотувати аудіо вперед / назад
* відкривати список розділів (key points) і переходити до вибраного
* обробляти перехід додатку у background / foreground

---

## Основний сценарій роботи

1. При запуску додатку:

   * `MiniBookPlayerFeature` отримує `.onAppear`
   * виконується завантаження книги через `BookRepository`
   * створюється `PlayerFeature.State` для першого розділу

2. Відтворення аудіо:

   * кожен розділ відповідає одному аудіофайлу
   * аудіо завантажується та програється через `AudioPlayerService`
   * прогрес оновлюється через async stream події

3. Background / Foreground:

   * при переході у background створюється `PlayerSnapshot`
   * snapshot зберігається локально в UserDefaults
   * при поверненні у foreground стан плеєра відновлюється

---

## Архітектура

Додаток побудований з використанням **The Composable Architecture (TCA)** та Clean Architecture.

### Рівні архітектури

#### UI (SwiftUI)

* `MiniBookPlayerView`
* `MiniBookPlayerViewContent`
* окремі reusable-компоненти (`ControlsView`, `ProgressAudioView`, `KeyPointsListView`, тощо)

UI:

* не містить бізнес-логіки
* відправляє actions у store
* відображає state

#### Features (Reducers)

**MiniBookPlayerFeature**

* відповідає за:

  * життєвий цикл додатку
  * завантаження книги
  * відновлення стану з snapshot
  * композицію `PlayerFeature`

**PlayerFeature**

* відповідає за:

  * відтворення аудіо
  * перемикання розділів
  * швидкість, seek, playback state
  * реакцію на події аудіоплеєра

#### Domain / Models

* `Book`, `KeyPoint`
* `PlayerSnapshot`

#### Services / Dependencies

* `BookRepository`

  * завантаження книги
  * збереження / відновлення snapshot

* `LoadBookService`

  * читання локального JSON з ресурсів

* `AudioPlayerService`

  * обгортка над `AVAudioPlayer`
  * асинхронні події прогресу та завершення відтворення

* `PlayerSnapshotStorage`

  * збереження snapshot у `UserDefaults`

Всі сервіси інтегровані через **TCA Dependencies**, що спрощує тестування.

---

## Збереження та відновлення стану

При переході додатку у background:

* формується `PlayerSnapshot`
* зберігається:

  * id книги
  * індекс поточного розділу
  * поточний час
  * швидкість відтворення

При поверненні у foreground:

* snapshot завантажується
* плеєр відновлюється у відповідному стані

---

## Юніт-тести

У проєкті присутні юніт-тести для ключових частин логіки:

* **BookRepository**

  * перевірка сценаріїв завантаження книги
  * перевірка роботи зі snapshot

* **MiniBookPlayerFeature**

  * `onAppear`
  * `loadBook / bookLoaded / loadingFailed`
  * `appMovedToBackground`
  * `appReturnedToForeground`

Тести побудовані з використанням `TestStore` з TCA та ізольованих dependency mocks.

---

## Технології

* Swift
* SwiftUI
* The Composable Architecture (TCA)
* AVFoundation
* Async / Await
* UserDefaults (для snapshot)

---

## Примітки

Проєкт є демонстраційним та фокусується на:

* архітектурі
* керуванні станом
* тестованості
