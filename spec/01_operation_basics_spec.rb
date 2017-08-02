require 'spec_helper'

describe 'Operation Basics' do
  context 'Empty Operation' do
    module BlogPost0
      class Create < Trailblazer::Operation
      end
    end

    it 'does nothing' do
      result = BlogPost0::Create.({})
      puts result
      
      expect(result.success?).to be_truthy
      expect(result.failure?).to be_falsy
      expect(result["model"]).to be_nil
    end
  end

  context 'Baby Steps' do
    module BlogPost1
      class Create < Trailblazer::Operation
        step :hello_world!

        def hello_world!(options, *)
          puts 'Hello, Trailblazer!'
          true # because puts always returns nil
        end
      end
    end

    it "puts Hello" do
      expect{
        result = BlogPost1::Create.()
        expect(result.success?).to be_truthy
        }.to output("Hello, Trailblazer!\n").to_stdout
    end
  end

  context 'Multiple steps' do
    context 'all steps succed' do
      module BlogPost2
        class Create < Trailblazer::Operation
          step :hello_world!
          step :how_are_you?

          def hello_world!(options, *)
            puts 'Hello, Trailblazer!'
            true
          end

          def how_are_you?(options, *)
            puts 'How are you?'  
            true
          end
        end
      end

      it do
        expect {
          result = BlogPost2::Create.()
          expect(result.success?).to be_truthy
        }.to output("Hello, Trailblazer!\nHow are you?\n").to_stdout
      end
    end

    context 'first step fails' do
      module BlogPost3
        class Create < Trailblazer::Operation
          step :hello_world!
          step :how_are_you?

          def hello_world!(options, *)
            puts 'Hello, Trailblazer!'
            #true
          end

          def how_are_you?(options, *)
            puts 'How are you?'  
            true
          end
        end
      end

      it do
        expect {
          result = BlogPost3::Create.()
          expect(result.success?).to be_falsy
        }.to output("Hello, Trailblazer!\n").to_stdout
      end
    end

    context 'Success! - skip checking returned value' do
      module BlogPost4
        class Create < Trailblazer::Operation
          success :hello_world!
          success :how_are_you?

          def hello_world!(options, *)
            puts 'Hello, Trailblazer!'
          end

          def how_are_you?(options, *)
            puts 'How are you?'  
          end
        end
      end

      it do
        expect {
          result = BlogPost2::Create.()
          expect(result.success?).to be_truthy
        }.to output("Hello, Trailblazer!\nHow are you?\n").to_stdout
      end
    end

    context 'check input' do
      module BlogPost5
        class Create < Trailblazer::Operation
          success :hello_world!
          step    :how_are_you?
          success :enjoy_your_day!

          def hello_world!(options, *)
            puts "Hello, Trailblazer!"
          end

          def how_are_you?(options, params:, **)
            puts "How are you?"

            params[:happy] == "yes"
          end

          def enjoy_your_day!(options, *)
            puts "Good to hear, have a nice day!"
          end
        end
      end

      it 'gets positive answer' do
        expect {
          result = BlogPost5::Create.( {happy: "yes"} )
          expect(result.success?).to be_truthy
        }.to output("Hello, Trailblazer!\nHow are you?\nGood to hear, have a nice day!\n").to_stdout
      end
      it 'gets negative answer' do
        expect {
          result = BlogPost5::Create.( {happy: "i'm sad!"})
          expect(result.success?).to be_falsy
        }.to output("Hello, Trailblazer!\nHow are you?\n").to_stdout
      end
    end

    context 'react on failed step' do
      module BlogPost6
        class Create < Trailblazer::Operation
          success :hello_world!
          step    :how_are_you?
          success :enjoy_your_day!
          failure :tell_joke!

          def hello_world!(options, *)
            puts "Hello, Trailblazer!"
          end

          def how_are_you?(options, params:, **)
            puts "How are you?"

            params[:happy] == "yes"
          end

          def enjoy_your_day!(options, *)
            puts "Good to hear, have a nice day!"
          end

          def tell_joke!(options, *)
            options["joke"] = "Broken pencils are pointless."
          end
        end
      end

      it do
        expect {
          result = BlogPost6::Create.( {happy: "i'm sad!"})
          expect(result.success?).to be_falsy
          expect(result["joke"]).to eq("Broken pencils are pointless.")
        }.to output("Hello, Trailblazer!\nHow are you?\n").to_stdout
      end
    end

  end
end