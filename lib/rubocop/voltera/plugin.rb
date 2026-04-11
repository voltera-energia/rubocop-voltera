# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Voltera
    # A plugin that integrates rubocop-voltera with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-voltera',
          version: VERSION,
          homepage: 'https://github.com/voltera-energia/rubocop-voltera',
          description: 'Custom RuboCop cops for Voltera projects.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
