include("header.jl")

@testset "JLD" begin

    #needed for load macro test: https://github.com/simonster/JLD2.jl/blob/cc56a4d6da116d6172a4ea89f4bec9d17154a0ba/test/loadsave.jl#L5L17
    fn = joinpath(tempdir(), "test.jld2")
    Knet.save(fn,"model",rnninit(1,1))

    @eval begin
        function macro_load()
            Knet.@load $fn
            model2 = rnninit(1,1)
            return all(typeof.(model).==typeof.(model2))
         end
    end

    #@test macro_load()


    function macro_save()
        model = rnninit(1,1)
        Knet.@save fn model
        true
     end

    @test macro_save()
    @test macro_load()

    function fun_sl()
        model = rnninit(1,1)
        Knet.save(fn,"model",model)
        model2 = Knet.load(fn,"model")
        all(typeof.(model).==typeof.(model))
    end

    @test fun_sl()

    function collections_sl()
        model  = rnninit(1,1)
        model2 = rnninit(1,1)
        Knet.save(fn,"model",[model,model2])
        models = Knet.load(fn,"model")
        test1 = all(typeof.(models[1]).==typeof.(model))
        Knet.save(fn,"model",(model,model2))
        models = Knet.load(fn,"model")
        test2 = all(typeof.(models[1]).==typeof.(model))
        Knet.save(fn,"model",Dict("model"=>model,"model2"=>model2))
        models = Knet.load(fn,"model")
        test3 = all(typeof.(models["model"]).==typeof.(model))
        Knet.save(fn,Dict("model"=>model,"model2"=>model2))
        models = Knet.load(fn)
        test3 = all(typeof.(models["model"]).==typeof.(model))
        test1 && test2 && test3
    end

    @test collections_sl()
end
