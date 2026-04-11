# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module RuboCop
  module Cop
    module Voltera
      # Ensures that `by_*` scopes whose arguments are plural-compatible
      # (i.e., work with both single values and arrays) use plural names.
      #
      # A scope is considered plural-compatible when its single argument
      # is used as a value in `where` hash conditions AND is not used in
      # any singular-only context. Rails handles both single values and
      # arrays transparently in `where` hash conditions.
      #
      # Scopes that use ILIKE/LIKE, call methods on the argument,
      # build ranges, use case statements, or use the argument as a
      # boolean switch are considered singular-only and are not flagged.
      #
      # @example
      #   # bad
      #   scope :by_company_id, ->(company_id) { where(company_id:) }
      #
      #   # good
      #   scope :by_company_ids, ->(company_ids) { where(company_id: company_ids) }
      #
      #   # good — singular name is correct for ILIKE scopes
      #   scope :by_name_segment, ->(segment) { where('name ilike ?', "%#{segment}%") }
      class ScopePluralNaming < Base
        MSG = 'Scope `:%<name>s` is plural-compatible but has a singular name. ' \
              'Consider renaming to `:%<suggested>s`.'

        GUARD_METHODS = %i[present? blank? nil? empty?].to_set.freeze

        # scope :by_x, lambda { |arg| body }
        # scope :by_x, ->(arg) { body }
        # @!method scope_with_lambda(node)
        def_node_matcher :scope_with_lambda, <<~PATTERN
          (send nil? :scope
            (sym $_)
            (block
              {(send nil? :lambda) (lambda)}
              (args (arg $_))
              $_))
        PATTERN

        def on_send(node)
          scope_with_lambda(node) do |name, arg_name, body|
            check_scope(node, name, arg_name, body)
          end
        end

        # scope(:by_x) { |arg| body }
        # @!method scope_with_block(node)
        def_node_matcher :scope_with_block, <<~PATTERN
          (block
            (send nil? :scope (sym $_))
            (args (arg $_))
            $_)
        PATTERN

        def on_block(node)
          scope_with_block(node) do |name, arg_name, body|
            check_scope(node, name, arg_name, body)
          end
        end

        private

        def check_scope(node, name, arg_name, body)
          name_str = name.to_s
          return unless name_str.start_with?('by_')
          return if already_plural?(name_str)
          return unless body
          return unless plural_compatible?(body, arg_name)

          suggested = suggest_plural(name_str)
          sym_node = find_scope_name_node(node)
          add_offense(sym_node || node, message: format(MSG, name: name_str, suggested:))
        end

        def find_scope_name_node(node)
          if node.send_type?
            node.first_argument
          else
            # block node — the sym is inside the send
            node.send_node.first_argument
          end
        end

        def already_plural?(name)
          last_word = name.split('_').last
          last_word == last_word.pluralize
        end

        # A scope is plural-compatible when:
        # 1. The arg is used at least once in a where-hash value position
        # 2. The arg is NOT used in any singular-only context
        # 3. The arg is not guarded with .nil? (indicating a boolean filter)
        def plural_compatible?(body, arg_name)
          found_where_hash_use = false
          found_singular_use = false

          body.each_descendant(:lvar) do |lvar|
            next unless lvar.children[0] == arg_name

            if in_where_hash_value?(lvar)
              found_where_hash_use = true
            elsif guard_use?(lvar)
              # A .nil? guard signals a boolean filter — the author used .nil?
              # instead of .present? because false.present? is false.
              return false if lvar.parent.method_name == :nil?
            else
              # Any other use (string interpolation, method arg, range,
              # bare if condition, case subject, etc.) is singular-only
              found_singular_use = true
            end
          end

          found_where_hash_use && !found_singular_use
        end

        def in_where_hash_value?(lvar)
          # Walk up from lvar through pair → hash → (pair → hash)* → where send
          current = lvar
          while current.parent
            parent = current.parent
            case parent.type
            when :pair
              # Must be the value (second child), not the key
              return false if parent.children[0] == current

              current = parent
            when :hash
              current = parent
            when :send
              return parent.method_name == :where
            else
              return false
            end
          end
          false
        end

        def guard_use?(lvar)
          parent = lvar.parent
          return false unless parent&.send_type?
          return false unless parent.receiver == lvar

          GUARD_METHODS.include?(parent.method_name)
        end

        def suggest_plural(name)
          parts = name.split('_')
          parts[-1] = parts[-1].pluralize
          parts.join('_')
        end
      end
    end
  end
end
