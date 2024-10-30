import 'package:flutter/material.dart';

import '../master.dart';

class CreateCustomField extends StatefulWidget {
  final Widget? icon;
  final String text;
  final TextEditingController controller;
  final bool isObscure, enabled, autoFocus;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;
  final TextInputType keyBoardType;
  final TextInputAction inputAction;
  final String label;
  final int lines, minLines;
  final Color? borderColor;
  final Color? iconColor;
  final TextCapitalization textCapitalization;
  final InputBorder? border;

  const CreateCustomField(
      {Key? key,
      this.icon,
      required this.text,
      required this.controller,
      this.isObscure = false,
      this.validator,
      this.keyBoardType = TextInputType.text,
      this.inputAction = TextInputAction.next,
      this.label = '',
      this.lines = 1,
      this.minLines = 1,
      this.borderColor,
      this.iconColor,
      this.enabled = true,
      this.textCapitalization = TextCapitalization.none,
      this.onChange,
      this.autoFocus = false,
      this.border})
      : super(key: key);

  @override
  State<CreateCustomField> createState() => _CreateCustomFieldState();
}

class _CreateCustomFieldState extends State<CreateCustomField> {
  @override
  void initState() {
    if (widget.label.isNotEmpty) {
      widget.controller.text = widget.label;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: TextFormField(
        textCapitalization: widget.textCapitalization,
        enabled: widget.enabled,
        maxLines: widget.lines,
        autofocus: widget.autoFocus,
        minLines: widget.minLines,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: widget.keyBoardType,
        textInputAction: widget.inputAction,
        onChanged: widget.onChange,
        decoration: InputDecoration(
          border: widget.border ??
              OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(7.0),
              ),
          contentPadding: widget.icon == null
              ? widget.minLines != 1
                  ? const EdgeInsets.only(left: 10, top: 15)
                  : const EdgeInsets.only(left: 10)
              : const EdgeInsets.only(top: 15, bottom: 15),
          prefixIcon: widget.icon == null
              ? null
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: widget.icon,
                ),
          prefixIconConstraints: const BoxConstraints(maxHeight: 25),
          hintText: widget.text,
          labelText: widget.text,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        obscureText: widget.isObscure,
        validator: widget.validator,
      ),
    );
  }
}

class CreateSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Color? borderColor;
  final Widget? icon;
  final void Function(String?)? onSearched;
  final void Function(String?)? onChanged;
  final GestureTapCallback? onTap;
  final bool autoFocus;

  const CreateSearchField(
      {Key? key,
      required this.controller,
      this.borderColor,
      this.icon,
      this.onSearched,
      this.onTap,
      this.onChanged,
      this.autoFocus = true})
      : super(key: key);

  @override
  _CreateSearchFieldState createState() => _CreateSearchFieldState();
}

class _CreateSearchFieldState extends State<CreateSearchField> {
  final _searchKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _searchKey,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextFormField(
          maxLines: 1,
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.disabled,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          autofocus: widget.autoFocus,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
              prefixIcon: widget.icon,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: pColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.only(top: 5, left: 10),
              // constraints:
              //     BoxConstraints.tight(MediaQuery.of(context).size * .05),
              hintText: 'Type here for search',
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: widget.onTap,
                      icon: const Icon(Icons.clear, color: red))
                  : null),
          onFieldSubmitted: widget.onSearched,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter something to search';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class CreatePasswordField extends StatefulWidget {
  final Widget? icon;
  final String text;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String?)? onSubmit;
  final InputBorder? border;

  const CreatePasswordField(
      {Key? key,
      this.icon,
      this.text = 'Password',
      required this.controller,
      this.validator,
      this.textInputAction = TextInputAction.done,
      this.onSubmit,
      this.border})
      : super(key: key);

  @override
  _CreatePasswordFieldState createState() => _CreatePasswordFieldState();
}

class _CreatePasswordFieldState extends State<CreatePasswordField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: TextFormField(
        maxLines: 1,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          suffixIcon: InkWell(
              onTap: () => setState(() {
                    isHidden = !isHidden;
                  }),
              child: Icon(isHidden ? Icons.visibility : Icons.visibility_off,
                  color: black)),
          border: widget.border ??
              OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(7.0),
              ),
          contentPadding: widget.icon == null
              ? const EdgeInsets.only(left: 10)
              : const EdgeInsets.only(top: 15, bottom: 15),
          prefixIcon: widget.icon == null
              ? null
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: getWidth(context) * .05),
                  child: widget.icon,
                ),
          prefixIconConstraints: const BoxConstraints(maxHeight: 25),
          hintText: widget.text,
          labelText: widget.text,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        obscureText: isHidden,
        validator: widget.validator,
        onFieldSubmitted: widget.onSubmit,
      ),
    );
  }
}
