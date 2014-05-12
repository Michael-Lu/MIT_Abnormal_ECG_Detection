function [TestNormal, TestAbNormal] = NormalizeFeature_Test(Parameters, NormTestFea, AbTestFea)
    TestNormal = cell2mat(NormTestFea);
    TestAbNormal = cell2mat(AbTestFea);
end