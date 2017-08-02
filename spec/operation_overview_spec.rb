require 'spec_helper'

describe 'Operation API' do
  context 'Empty Operation' do
    module Song
      class Create < Trailblazer::Operation

      end
    end

    it 'does nothing' do
      result = Song::Create.({})

      expect(result.success?).to be_truthy
      expect(result.failure?).to be_falsy
      expect(result["model"]).to be_nil
    end
  end

  context 'Building a Model' do
    context 'using Model Macro' do
      class Song0
        class Create < Trailblazer::Operation
          step Model(Song0, :new)
        end
      end

      it 'instantiates the model' do
        result = Song0::Create.({})

        expect(result.success?).to be_truthy
        expect(result.failure?).to be_falsy
        expect(result["model"]).to be_a(Song0)
      end
    end
  end

end