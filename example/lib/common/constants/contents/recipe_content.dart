import 'package:novident_editor/novident_editor.dart';

/// Content for `Novident Showcase ▸ Homemade Sourdough Bread`.
///
/// A realistic recipe that naturally uses bulleted lists (ingredients and
/// equipment), numbered lists (method) and a todo checklist (prep), plus a
/// quote for the baker's tip.
final Document recipeDocument = Document(
  root: pageNode(
    children: <Node>[
      headingNode(level: 1, text: 'Homemade Sourdough Bread'),
      paragraphNode(
        delta: Delta()
          ..insert('A ')
          ..insert('beginner-friendly',
              attributes: <String, dynamic>{RichTextKeys.bold: true})
          ..insert(' recipe for a crusty loaf with an open crumb. Total time '
              'is about 24 hours, but most of it is hands-off.'),
      ),
      headingNode(level: 2, text: 'Ingredients'),
      bulletedListNode(text: '500 g bread flour'),
      bulletedListNode(text: '350 g water, at room temperature'),
      bulletedListNode(text: '100 g active sourdough starter'),
      bulletedListNode(text: '10 g fine sea salt'),
      headingNode(level: 2, text: 'Equipment'),
      bulletedListNode(text: 'Dutch oven, or a heavy lidded pot'),
      bulletedListNode(text: 'Banneton, or a floured mixing bowl'),
      bulletedListNode(text: 'Razor blade or sharp knife, for scoring'),
      headingNode(level: 2, text: 'Method'),
      paragraphNode(
        text: 'The dough comes together in a few short steps spread across '
            'a day. The timing is forgiving — the dough waits for you, not '
            'the other way around.',
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Mix the flour and water. Cover and leave for 30 minutes '
              '(autolyse).'),
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Add the starter and salt. Mix until no dry flour remains.'),
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Bulk ferment for 4–5 hours, folding the dough every 30 '
              'minutes.'),
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Shape the loaf and place it seam-side up in the banneton.'),
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Cold proof overnight in the fridge, 8–12 hours.'),
      ),
      numberedListNode(
        delta: Delta()
          ..insert('Bake at 250 °C in a covered Dutch oven for 20 minutes, '
              'then uncovered for 25 minutes until deep golden.'),
      ),
      headingNode(level: 2, text: 'Prep checklist'),
      paragraphNode(
        text: 'A todo list keeps the timing straight across the two days:',
      ),
      todoListNode(checked: true, text: 'Feed the starter the night before'),
      todoListNode(checked: true, text: 'Mix the dough in the morning'),
      todoListNode(checked: false, text: 'Fold the dough four times'),
      todoListNode(checked: false, text: 'Shape and cold-proof'),
      todoListNode(checked: false, text: 'Preheat the oven and bake'),
      headingNode(level: 2, text: 'Baker\'s tips'),
      quoteNode(
        delta: Delta()
          ..insert(
            'A wetter dough gives a more open crumb, but it is harder to '
            'shape. Start at 70% hydration and adjust from there.',
          ),
      ),
      bulletedListNode(
        text: 'Use a kitchen scale — bread is about ratios, not cups.',
      ),
      bulletedListNode(
        text: 'Let the loaf cool completely before slicing, or the crumb '
            'will be gummy.',
      ),
      bulletedListNode(
        text: 'A well-fed, bubbly starter is the difference between a good '
            'loaf and a great one.',
      ),
    ],
  ),
);
