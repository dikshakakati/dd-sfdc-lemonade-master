/* global define */

(function () {
	'use strict';

	var hasOwn = {}.hasOwnProperty;
  
  function formatNumber(value,format) {
    if (!format) format = "0,0.00";

    const type = typeof value;

    if (type === 'object' || type === 'function' || type === 'boolean')
      return null;

    const n = numeral(value);

    if (n.value() === 0 && (value !== 0 && value !== '0' &&
        parseFloat(value) !== 0 ))
      return null;

    if (isNaN(n.value())) {
      return null;
    }

    return (n ? n.format(format) : '');
  } 

	if (typeof module !== 'undefined' && module.exports) {
		module.exports = formatNumber;
    
	} else if (typeof define === 'function' && typeof define.amd === 'object' && define.amd) {
		define('formatNumber', [], function () {
			return formatNumber;
		});
	} else {
		window.formatNumber = formatNumber;
	}
}());



