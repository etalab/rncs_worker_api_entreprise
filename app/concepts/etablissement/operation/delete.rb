class Etablissement
  module Operation
    class Delete < Trailblazer::Operation
      step :find_etablissement
      fail :warning_message, Output(:success) => 'End.success'
      step :delete

      def find_etablissement(ctx, data:, **)
        ctx[:etablissement] = Etablissement.find_by(
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion],
          id_etablissement: data[:id_etablissement]
        )
      end

      def delete(_ctx, etablissement:, **)
        etablissement.delete
      end

      def warning_message(ctx, data:, **)
        ctx[:warning] = "The etablissement with id (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}, id_etablissement: #{data[:id_etablissement]}) does not exist in the database and cannot be deleted"
      end
    end
  end
end
