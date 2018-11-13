class Representant
  module Operation
    class Delete < Trailblazer::Operation
      step :find_representant
        fail :warning_message, Output(:success) => 'End.success'
      step :delete


      def find_representant(ctx, data:, **)
        ctx[:representant] = Representant.find_by(
          code_greffe: data[:code_greffe],
          numero_gestion: data[:numero_gestion],
          id_representant: data[:id_representant],
          qualite: data[:qualite],
        )
      end

      def delete(ctx, representant:, **)
        representant.delete
      end

      def warning_message(ctx, data:, **)
        ctx[:warning] = "The representant with id (code_greffe: #{data[:code_greffe]}, numero_gestion: #{data[:numero_gestion]}, id_representant: #{data[:id_representant]}, qualite: #{data[:qualite]}) does not exist in the database and cannot be deleted"
      end
    end
  end
end
