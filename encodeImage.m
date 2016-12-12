function psi = encodeImage(encoder, im, cache)


if ~iscell(im), im = {im} ; end
if nargin <= 2, cache = [] ; end

psi = cell(1,numel(im)) ;
if numel(im) > 1
  %par
  for i = 1:numel(im)
    %fprintf('%05d of %05d\n', i, numel(im)) ;
    psi{i} = processOne(encoder, im{i}, cache) ;
  end
elseif numel(im) == 1
  psi{1} = processOne(encoder, im{1}, cache) ;
end
psi = horzcat(psi{:}) ;

% --------------------------------------------------------------------
function psi = processOne(encoder, im, cache)
% --------------------------------------------------------------------
if isstr(im)
  if ~isempty(cache)
    psi = getFromCache(im, cache) ;
    if ~isempty(psi), return ; end
  end
  %fprintf('encoding image %s\n', im) ;
end

psi = encodeOne(encoder, im) ;

if isstr(im) & ~isempty(cache)
  storeToCache(im, cache, psi) ;
end

% --------------------------------------------------------------------
function psi = encodeOne(encoder, im)
% --------------------------------------------------------------------
im = standardizeImage(im) ;
im_ = bsxfun(@minus, 255*im, encoder.averageColor) ;
res = vl_simplenn(encoder.net, im_) ;
psi = mean(reshape(res(end).x, [], size(res(end).x,3)), 1)' ;

% --------------------------------------------------------------------
function psi = getFromCache(name, cache)
% --------------------------------------------------------------------
[drop, name] = fileparts(name) ;
cachePath = fullfile(cache, [name '.mat']) ;
if exist(cachePath, 'file')
  data = load(cachePath) ;
  psi = data.psi ;
else
  psi = [] ;
end

% --------------------------------------------------------------------
function storeToCache(name, cache, psi)
% --------------------------------------------------------------------
[drop, name] = fileparts(name) ;
cachePath = fullfile(cache, [name '.mat']) ;
vl_xmkdir(cache) ;
data.psi = psi ;
save(cachePath, '-STRUCT', 'data') ;
