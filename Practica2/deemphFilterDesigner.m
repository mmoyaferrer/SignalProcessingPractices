function [sosMatrix, ScaleValues] = deemphFilterDesigner...
        (pFs,FilterTimeConstant)
      bs = [0 1];
      as = [FilterTimeConstant 1];
      [bz,az] = bilinear(bs, as, pFs, 1/(2*pi*FilterTimeConstant));
      [Az,Fz] = freqz(bz , az, 2048, pFs);
      filtDesigner = fdesign.arbmag('N,B,F,A', 5, 1, Fz, abs(Az), pFs);
      DeemphFilter = design(filtDesigner,'iirlpnorm');
      sosMatrix = DeemphFilter.sosMatrix;
      ScaleValues = DeemphFilter.ScaleValues;
    end

