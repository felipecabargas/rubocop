# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for ambiguous regexp literals in the first argument of
      # a method invocation without parentheses.
      #
      # @example
      #
      #   # bad
      #
      #   # This is interpreted as a method invocation with a regexp literal,
      #   # but it could possibly be `/` method invocations.
      #   # (i.e. `do_something./(pattern)./(i)`)
      #   do_something /pattern/i
      #
      # @example
      #
      #   # good
      #
      #   # With parentheses, there's no ambiguity.
      #   do_something(/pattern/i)
      #
      # @api private
      class AmbiguousRegexpLiteral < Base
        extend AutoCorrector

        MSG = 'Ambiguous regexp literal. Parenthesize the method arguments ' \
              "if it's surely a regexp literal, or add a whitespace to the " \
              'right of the `/` if it should be a division.'

        def on_new_investigation
          processed_source.diagnostics.each do |diagnostic|
            next unless diagnostic.reason == :ambiguous_literal

            offense_node = find_offense_node_by(diagnostic)

            add_offense(diagnostic.location, severity: diagnostic.level) do |corrector|
              add_parentheses(offense_node, corrector)
            end
          end
        end

        private

        def find_offense_node_by(diagnostic)
          node = processed_source.ast.each_node(:regexp).find do |regexp_node|
            regexp_node.source_range.begin_pos == diagnostic.location.begin_pos
          end

          node.parent
        end
      end
    end
  end
end
